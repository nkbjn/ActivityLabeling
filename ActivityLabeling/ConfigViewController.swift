//
//  ConfigViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka

class ConfigViewController: FormViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"

        form
            +++ Section(header:"接続先", footer:"InfluxDBへの接続先情報を入力してください")
            
                <<< URLRow() {
                    $0.title = "IP/ホスト名"
                    $0.value = defaults.url(forKey: Config.host)
                }.onChange { row in
                    self.defaults.set(row.value, forKey: Config.host)
            }
            
            +++ Section(header:"行動ラベル", footer:"") {
                
                $0 <<< ButtonRow(){
                    $0.title = "変更"
                    $0.presentationMode = .segueName(segueName: "ActivitySelectViewControllerControllerSegue", onDismiss: nil)
                }
                
            }
            
            +++ Section(header:"ラベリング周期", footer:"")
                
                <<< IntRow() {
                    $0.title = "周期(s)"
                    $0.value = defaults.integer(forKey: Config.period)
                }.onChange { row in
                    self.defaults.set(row.value, forKey: Config.period)
        }
    }
    
}
