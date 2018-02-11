//
//  LabelingViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

class LabelingViewController: FormViewController {
    
    var timer: Timer?
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    let activityList = UserDefaults.standard.stringArray(forKey: Config.activityList)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベリング"
        
        let period = defaults.integer(forKey: Config.period)
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(period), target: self, selector: #selector(LabelingViewController.save), userInfo: nil, repeats: true)
        
        
        form
            +++ MultivaluedSection(multivaluedOptions:[], footer: "") {
                $0.tag = Config.activityList
        
                for activity in activityList! {
                    $0 <<< SwitchRow {
                        $0.title = activity
                        $0.value = false
                        }.onChange{row in
                            row.cell.backgroundColor = row.value! ? UIColor.darkGray : UIColor.white
                            row.cell.textLabel?.textColor = row.value! ? UIColor.white : UIColor.black
                    }
                }
                
            }
        
            +++ Section(header:"", footer:"")
            
                <<< ButtonRow() {
                    $0.title = "ラベリング終了"
                }.onCellSelection { _, _ in
                    let alert = UIAlertController(title: "ラベリング終了",
                                                  message: "本当に終了してよろしいですか？",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "終了",
                                                  style: .default,
                                                  handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
            }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
    @objc func save() {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        let label = Label()
        for (name, value) in zip(activityList!, section.values()) {
            if let isOn = value as? Bool {
                if isOn {
                    let activity = Activity()
                    activity.name = name
                    label.activities.append(activity)
                }
            }
        }
        try! realm.write {
            realm.add(label)
        }
    }
    
    @objc func writeRequest() {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        for (name, value) in zip(activityList!, section.values()) {
            if let isOn = value as? Bool {
                if isOn {
                    let database = defaults.string(forKey: Config.database)
                    let measurement = defaults.string(forKey: Config.measurement)
                    let field = defaults.string(forKey: Config.field)
                    let host = defaults.string(forKey: Config.host)
                }
            }
        }
    }

}
