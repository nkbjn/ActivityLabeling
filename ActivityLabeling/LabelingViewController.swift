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
import APIKit
import ChameleonFramework

class LabelingViewController: FormViewController {
    
    var id: String?
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    let activityList = UserDefaults.standard.stringArray(forKey: Config.activityList)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
        self.title = "行動未選択"
        save()
        
        form
            +++ MultivaluedSection(multivaluedOptions:[]) {
                $0.tag = Config.activityList
        
                for activity in activityList! {
                    $0 <<< SwitchRow {
                        $0.tag = activity
                        $0.title = activity
                        $0.value = false
                    }.onChange{row in
                        row.cell.backgroundColor = row.value! ? UIColor.flatWhiteDark : UIColor.white
                        self.write(tag: row.tag!)
                    }.cellSetup() {cell, row in
                        cell.switchControl.onTintColor = UIColor.flatGreen
                    }
                }
                
            }
        
            +++ Section()
            
                <<< ButtonRow() {
                    $0.title = "ラベリング終了"
                }.onCellSelection { _, _ in
                    if self.selectedCheck() {
                        let alert = UIAlertController(title: "エラー",
                                                      message: "全ての行動を終了させてください",
                                                      preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    
                    
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
    
    func selectedCheck() -> Bool {
        let section = self.form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        
        for value in section.values() {
            if let isOn = value as? Bool {
                if isOn {
                    return true
                }
            }
        }
        return false
    }
    
    func save() {
        let labeling = Labeling()
        self.id = labeling.id
        labeling.host = self.defaults.string(forKey: Config.host)!
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(labeling)
        }
    }
    
    
    func add(activity:String, on:Bool) {
        let labeling = realm.object(ofType: Labeling.self, forPrimaryKey: self.id)
        let label = Label()
        label.activity = activity
        label.on = on
        try! realm.write {
            labeling?.labels.append(label)
        }
    }
    
    func write(tag:String) {
        let row = form.rowBy(tag: tag) as! SwitchRow
        let activity = row.title!
        let on = row.value!
        
        var fields: [String: Any] = [:]
        fields["activity"] = activity
        fields["on"] = on ? 1:0
        
        let database = defaults.string(forKey: Config.database)!
        let measurement = defaults.string(forKey: Config.measurement)!
        let host = defaults.string(forKey: Config.host)!
        let influxdb = InfluxDBClient(host: URL(string: host)!, databaseName: database)
        let request = WriteRequest(influxdb: influxdb, measurement: measurement, tags: [:], fields: fields)
        
        Session.send(request) { result in
            switch result {
            case .success:
                self.add(activity: activity, on: on)
                self.navigationController?.navigationBar.barTintColor = UIColor.flatMintDark
                self.title = "通信成功"
                if !self.selectedCheck() {
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
                    self.title = "行動未選択"
                }
            case .failure:
                row.value = on ? false:true
                self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
                self.title = "通信失敗"
            }
        }
    }

}
