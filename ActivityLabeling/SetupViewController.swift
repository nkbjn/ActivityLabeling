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
    
    let api = APIManager.shared
    
    
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
            
            
            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "Start Labeling"
                
            }.onCellSelection {_, _ in
                self.startLabeling()
            }
        
    }
    
    
    /// DBサーバへの接続テストを行う
    func connectionTest() {
        self.api.test(handler: {error in
            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            let alert = UIAlertController(title: "Success",
                                          message: "Connection successed.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        })
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
        let alert = UIAlertController(title: "Initialize settings", message: "Do you really want to initialize settings?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            // 初期設定に戻す
            DefaultConfig().reset()
            
            // 入力エリアの表示も更新する
            let ssl = self.form.rowBy(tag: Config.ssl) as! SwitchRow
            ssl.value = self.defaults.bool(forKey: Config.ssl)
            ssl.reload()
            
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
