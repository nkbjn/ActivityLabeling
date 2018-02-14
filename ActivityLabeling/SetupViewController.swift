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

class SetupViewController: FormViewController {

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベリング"
        
        form
            +++ Section("ラベルデータを保存するデータベースの設定")
            
            <<< TextRow() {
                $0.tag = Config.host
                $0.title = "接続先"
                $0.value = defaults.string(forKey: Config.host)
                }.onChange { row in
                    self.defaults.set(row.value, forKey: Config.host)
            }
            
            <<< ButtonRow() {
                $0.title = "接続テスト"
                }.onCellSelection { _, _ in
                    self.ping()
                }
            
            +++ Section("ラベリングする行動の設定")
            
            <<< ButtonRow(){
                $0.title = "対象行動の確認/変更"
                $0.presentationMode = .segueName(segueName: "ActivitySelectViewControllerControllerSegue", onDismiss: nil)
            }
            
            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "ラベリング開始"
                }.onCellSelection { _, _ in
                    self.start()
                }
        
    }
    
    func ping() {
        let database = self.defaults.string(forKey: Config.database)
        let host = self.defaults.string(forKey: Config.host)
        let influxdb = InfluxDBClient(host: URL(string: host!)! ,databaseName: database!)
        let request = PingRequest(influxdb: influxdb)
        
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
    
    func start() {
        let host = defaults.string(forKey: Config.host)!
        let activityList = defaults.stringArray(forKey: Config.activityList)!
        
        var message = "接続先：\(host) \n\n"
        message = message + "対象行動\n"
        for activity in activityList {
            message = message + "・\(activity)\n"
        }
        
        let alert = UIAlertController(title: "ラベリング開始", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "開始", style: .default, handler: { action in
            self.performSegue(withIdentifier: "LabelingViewControllerSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func reset(_ sender: Any) {
        let alert = UIAlertController(title: "設定の初期化", message: "本当に初期化してよろしいですか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetConfig()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func resetConfig() {
        DefaultConfig().reset()
        
        let host = form.rowBy(tag: Config.host) as! TextRow
        host.value = defaults.string(forKey: Config.host)
        host.reload()
    }
    
}


class ActivitySelectViewController: FormViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "行動ラベル"
        
        let activityList = defaults.stringArray(forKey: Config.activityList)
        
        form +++
            MultivaluedSection(multivaluedOptions:[.Insert, .Delete], footer: "") {
                
                $0.tag = Config.activityList
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "行動ラベルを追加"
                        }.cellUpdate { cell, row in
                            cell.textLabel?.textAlignment = .left
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return TextRow() {
                        $0.placeholder = "行動名"
                    }
                }
                
                for activity in activityList! {
                    $0 <<< TextRow {
                        $0.placeholder = "行動名"
                        $0.value = activity
                    }
                }
                
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        defaults.set(section.values(), forKey: Config.activityList)
    }
    
}
