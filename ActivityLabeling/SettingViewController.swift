//
//  SettingViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka

class SettingViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"

        form
            +++ Section(header:"接続先", footer:"InfluxDBのURLを入力してください")
            
                <<< URLRow() {
                    $0.title = "URL"
                    $0.add(rule: RuleURL())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
            
            +++ Section(header:"行動ラベル", footer:"")
            
            <<< ButtonRow(){
                $0.title = "変更"
                $0.presentationMode = .segueName(segueName: "ActivitySelectViewControllerControllerSegue", onDismiss: nil)
        }
    }
}
