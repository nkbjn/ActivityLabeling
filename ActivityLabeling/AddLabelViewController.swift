//
//  AddLabelViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/07/25.
//  Copyright © 2018 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka
import APIKit

class AddLabelViewController: FormViewController {
    
    let activities = UserDefaults.standard.array(forKey: Config.activities)! as! [String]
    
    let api = APIManager.shared
    
    var calendar = Calendar(identifier: .gregorian)
    var components = DateComponents()
    var activity = ""
    var status = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        self.components = self.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        self.activity = self.activities[0]

        form
            +++ Section("label info")
            
            <<< DateRow() {
                $0.title = "Date"
                $0.value = calendar.date(from: components)
                }.onChange { row in
                    self.components.year = self.calendar.component(.year, from: row.value!)
                    self.components.month = self.calendar.component(.month, from: row.value!)
                    self.components.day = self.calendar.component(.day, from: row.value!)
            }
            <<< IntRow() {
                $0.title = "Hour"
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 23))
                $0.value = self.components.hour
                }.cellUpdate{ cell, row in
                    if !row.isValid {
                        row.value = 0
                    }
                }.onChange { row in
                    if let hour = row.value {
                        self.components.hour = hour
                    }
            }
            <<< IntRow() {
                $0.title = "Minute"
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 59))
                $0.value = self.components.minute
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        row.value = 0
                    }
                }.onChange { row in
                    if let minute = row.value {
                        self.components.minute = minute
                    }
            }
            <<< IntRow() {
                $0.title = "Second"
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 59))
                $0.value = self.components.second
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        row.value = 0
                    }
                }.onChange {row in
                    if let second = row.value {
                        self.components.second = second
                    }
            }
            <<< AlertRow<String>() {
                $0.title = "Activity"
                $0.selectorTitle = "Activity"
                $0.value = self.activity
                $0.options = activities
                }.onChange {row in
                    self.activity = row.value!
            }
            <<< AlertRow<String>() {
                $0.title = "Start / Finish"
                $0.value = "Start"
                $0.options = ["Start", "Finish"]
                }.onChange {row in
                    self.status = row.value! == "Start"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func add(_ sender: Any) {
        let time = self.calendar.date(from: self.components)
        self.api.write(time: time!, activity: activity, status: status, handler: { error in

            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }

            self.dismiss(animated: true, completion: nil)
        })
        
    }
    

}
