//
//  SetupViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka
import APIKit


/// ラベリングの設定を行うViewController
class SetupViewController: FormViewController {

    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Labeling"
        
        form
            +++ Section("Datababe Config")
            
            <<< SwitchRow() {
                $0.tag = Config.ssl
                $0.title = "SSL"
                $0.value = defaults.bool(forKey: Config.ssl)
                
            }.onChange {row in
                // 内容が変更されたらUserdefaultsに書き込む
                self.defaults.set(row.value, forKey: Config.ssl)
            }
            
            <<< AccountRow() {
                $0.tag = Config.host
                $0.title = "Host"
                $0.placeholder = "Host"
                $0.value = defaults.string(forKey: Config.host)
                
            }.onChange {row in
                // 内容が変更されたらUserdefaultsに書き込む
                self.defaults.set(row.value, forKey: Config.host)
            }
            
            <<< IntRow() {
                $0.tag = Config.port
                $0.title = "Port"
                $0.placeholder = "Port"
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
                $0.title = "User"
                $0.placeholder = "User"
                if let value = Keychain.user.value() {
                    $0.value = value
                }
                
                }.onChange {row in
                    // 内容が変更されたらKeyChainに書き込む
                    Keychain.user.set(row.value ?? "")
            }
            
            <<< PasswordRow() {
                $0.tag = Config.password
                $0.title = "Password"
                $0.placeholder = "Password"
                if let value = Keychain.password.value() {
                    $0.value = value
                }
                
                }.onChange {row in
                    // 内容が変更されたらKeyChainに書き込む
                    Keychain.password.set(row.value ?? "")
            }
            
            <<< ButtonRow() {
                $0.title = "Test Connection"
                
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
                $0.title = "Start Labeling"
                
            }.onCellSelection {_, _ in
                self.startLabeling()
            }
        
    }
    
    
    /// DBサーバへの接続テストを行う
    func connectionTest() {
        
        let host = defaults.string(forKey: Config.host)
        guard (host != nil) else {
            let alert = UIAlertController(title: "Error",
                                          message: "Please input host.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let port = defaults.integer(forKey: Config.port)
        let ssl = defaults.bool(forKey: Config.ssl)
        
        if let user = Keychain.user.value(),
            let password = Keychain.password.value() {
            
            let influxdb = InfluxDBClient(host: host!, port: port, user: user, password: password, ssl: ssl)
            let request = QueryRequest(influxdb: influxdb, query: "SHOW DATABASES")
            
            Session.send(request) { result in
                switch result {
                case .success:
                    let alert = UIAlertController(title: "Success",
                                                  message: "Connection successed.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                case .failure(let error):
                    let alert = UIAlertController(title: "Error",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                }
            }
        }
    }
    
    
    // ラベリングを開始する
    func startLabeling() {
        let alert = UIAlertController(title: "Start Labeling", message: "Would you like to start labeling?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { action in
            // ラベリング画面に遷移
            self.performSegue(withIdentifier: "LabelingViewControllerSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    // 設定を初期設定に戻す
    @IBAction func resetConfig(_ sender: Any) {
        let alert = UIAlertController(title: "Initialize settings", message: "Do you really want to initialize sttings?", preferredStyle: .alert)
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
            user.value = ""
            user.reload()
            
            let password = self.form.rowBy(tag: Config.password) as! PasswordRow
            password.value = ""
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
