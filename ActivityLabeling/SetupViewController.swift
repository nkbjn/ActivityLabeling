//
//  SetupViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka

class SetupViewController: FormViewController {

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベリング"
        tableView.isEditing = false
        
        form
            +++ Section(header:"行動ラベル", footer:"") {
            
                let activityList = defaults.stringArray(forKey: Config.activityList)
                for activity in activityList! {
                    $0 <<< TextRow() {
                        $0.value = activity
                        $0.disabled = true
                    }
                }
            }
            
            +++ Section(header:"ラベリング周期", footer:"")
            
                <<< IntRow() {
                    $0.title = "周期(s)"
                    $0.value = defaults.integer(forKey: Config.period)
                    $0.disabled = true
                }
        
            +++ Section()
            
                <<< ButtonRow() {
                    $0.title = "ラベリング開始"
                    $0.presentationMode = .segueName(segueName: "LabelingViewControllerSegue", onDismiss: nil)
                    }
        
    }

}
