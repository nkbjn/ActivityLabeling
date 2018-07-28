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
    
    let api = APIManager.shared
    var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    let activities = UserDefaults.standard.array(forKey: Config.activities)! as! [String]
    var activity = ""
    let statusList = ["Start", "Finish"]
    var status = true
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        guard let time = Calendar.current.date(from: self.components) else {
            let alert = UIAlertController(title: "Error", message: "Value error.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        self.api.write(time: time, activity: activity, status: status, handler: { error in
            
            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activity = self.activities.first!

        form
            +++ Section("label info")
            
            <<< DateRow() {
                $0.title = "Date"
                $0.value = Calendar.current.date(from: self.components)
                $0.cell.datePicker.locale = Locale(identifier: "en_US_POSIX")
                }.onChange { row in
                    if let date = row.value {
                        self.components.year = Calendar.current.component(.year, from: date)
                        self.components.month = Calendar.current.component(.month, from: date)
                        self.components.day = Calendar.current.component(.day, from: date)
                    }
            }
            
            <<< TriplePickerInputRow<Int, Int, Int>() {
                $0.title = "Time"
                $0.firstOptions = { return ([Int])(0...23) }
                $0.secondOptions = { _ in return ([Int])(0...59) }
                $0.thirdOptions = { _,_ in return ([Int])(0...59) }
                $0.value = Tuple3(a: self.components.hour!,
                                  b: self.components.minute!,
                                  c: self.components.second!)
                $0.displayValueFor = { value in
                    if let hour = value?.a,
                        let minute = value?.b,
                        let second = value?.c {
                        return String(format: "%02d:%02d:%02d", hour, minute, second)
                    }
                    return ""
                }
                $0.displayValueForFirstRow = { hour in
                    return String(format: "%d h", hour)
                }
                $0.displayValueForSecondRow = { minute in
                    return String(format: "%d m", minute)
                }
                $0.displayValueForThirdRow = { second in
                    return String(format: "%d s", second)
                }
                }.onChange { row in
                    if let value = row.value {
                        self.components.hour = value.a
                        self.components.minute = value.b
                        self.components.second = value.c
                    }
                }
            
            <<< PickerInputRow<String>() {
                $0.title = "Activity"
                $0.options = self.activities
                $0.value = $0.options.first
                }.onChange { row in
                    if let activity = row.value {
                        self.activity = activity
                    }
            }
            
            <<< PickerInputRow<String>() {
                $0.title = "Start / Finish"
                $0.options = self.statusList
                $0.value = $0.options.first
                }.onChange { row in
                    if let value = row.value {
                        self.status = value == self.statusList.first
                    }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
