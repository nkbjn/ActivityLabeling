//
//  SetupViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import APIKit


/// ラベリングの設定を行うViewController
class SetupViewController: FormViewController {

    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ラベリング"
        
        form
            +++ Section("データベースの設定")
            
            <<< AccountRow() {
                $0.tag = Config.host
                $0.title = "ホスト名"
                $0.placeholder = "ホスト名"
                $0.value = defaults.string(forKey: Config.host)
                
            }.onChange {row in
                // 内容が変更されたらUserdefaultsに書き込む
                self.defaults.set(row.value, forKey: Config.host)
            }
            
            <<< IntRow() {
                $0.tag = Config.port
                $0.title = "ポート番号"
                $0.placeholder = "ポート番号"
                $0.value = defaults.integer(forKey: Config.port)
                let formatter = NumberFormatter()
                formatter.numberStyle = .none
                $0.formatter = formatter
                
                }.onChange {row in
                    // 内容が変更されたらUserdefaultsに書き込む
                    self.defaults.set(row.value, forKey: Config.port)
            }
            
            <<< AccountRow() {
                $0.tag = Config.user
                $0.title = "ユーザ名"
                $0.placeholder = "ユーザ名"
                $0.value = defaults.string(forKey: Config.user)
                
                }.onChange {row in
                    // 内容が変更されたらUserdefaultsに書き込む
                    self.defaults.set(row.value, forKey: Config.user)
            }
            
            <<< PasswordRow() {
                $0.tag = Config.password
                $0.title = "パスワード"
                $0.placeholder = "パスワード"
                $0.value = defaults.string(forKey: Config.password)
                
                }.onChange {row in
                    // 内容が変更されたらUserdefaultsに書き込む
                    self.defaults.set(row.value, forKey: Config.password)
            }
            
            <<< ButtonRow() {
                $0.title = "接続テスト"
                
            }.onCellSelection {_, _ in
                self.connectionTest()
            }
            
            
            +++ Section("ラベリングする行動")
            
            <<< ButtonRow() {
                $0.title = "対象行動の確認"
                $0.presentationMode = .segueName(segueName: "ActivityTableViewControllerControllerSegue", onDismiss: nil)
            }
            
            
            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "ラベリング開始"
                
            }.onCellSelection {_, _ in
                self.startLabeling()
            }
        
    }
    
    
    /// DBサーバへの接続テストを行う
    func connectionTest() {
        
        let host = defaults.string(forKey: Config.host)
        guard (host != nil) else {
            let alert = UIAlertController(title: "エラー",
                                          message: "接続先ホストを入力してください",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let port = defaults.integer(forKey: Config.port)
        let user = defaults.string(forKey: Config.user)
        let password = defaults.string(forKey: Config.password)
        let influxdb = InfluxDBClient(host: host!, port: port, user: user, password: password)
        let request = QueryRequest(influxdb: influxdb, query: "SHOW DATABASES")
        
        Session.send(request) { result in
            switch result {
            case .success:
                let alert = UIAlertController(title: "通信成功",
                                              message: "正常に通信ができることを確認しました",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            case .failure(let error):
                let alert = UIAlertController(title: "通信エラー",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
        }
    }
    
    
    // ラベリングを開始する
    func startLabeling() {
        let alert = UIAlertController(title: "ラベリング開始", message: "ラベリングを開始しますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開始", style: .default, handler: { action in
            // ラベリング画面に遷移
            self.performSegue(withIdentifier: "LabelingViewControllerSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    // 設定を初期設定に戻す
    @IBAction func resetConfig(_ sender: Any) {
        let alert = UIAlertController(title: "設定の初期化", message: "本当に初期化してよろしいですか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            // 初期設定に戻す
            DefaultConfig().reset()
            
            // 入力エリアの表示も更新する
            let host = self.form.rowBy(tag: Config.host) as! AccountRow
            host.value = self.defaults.string(forKey: Config.host)
            host.reload()
            
            let port = self.form.rowBy(tag: Config.port) as! IntRow
            port.value = self.defaults.integer(forKey: Config.port)
            port.reload()
            
            let user = self.form.rowBy(tag: Config.user) as! AccountRow
            user.value = self.defaults.string(forKey: Config.user)
            user.reload()
            
            let password = self.form.rowBy(tag: Config.password) as! PasswordRow
            password.value = self.defaults.string(forKey: Config.password)
            password.reload()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}


/// ラベリング行動確認画面
class ActivityTableViewController: UITableViewController {
    
    let activityDict = UserDefaults.standard.dictionary(forKey: Config.activityDict)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "行動ラベル"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let key = Array(activityDict.keys)[indexPath.row]
        let activity = activityDict[key] as! String
        cell.textLabel?.text = activity
        
        return cell
    }

}
