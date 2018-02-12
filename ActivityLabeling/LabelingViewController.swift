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

class LabelingViewController: FormViewController {
    
    var id: String?
    var timer: Timer?
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    let activityList = UserDefaults.standard.stringArray(forKey: Config.activityList)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベリング"
        
        
        save()
        
        form
            +++ MultivaluedSection(multivaluedOptions:[]) {
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
        
            +++ Section()
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(LabelingViewController.willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willEnterForeground() {
        self.setTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    func setTimer() {
        if (self.timer?.isValid)! {
            return
        }
        let period = defaults.integer(forKey: Config.period)
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(period), target: self, selector: #selector(LabelingViewController.labeling), userInfo: nil, repeats: true)
    }
    
    func save() {
        let labeling = Labeling()
        self.id = labeling.id
        labeling.host = self.defaults.string(forKey: Config.host)!
        let activityList = self.defaults.stringArray(forKey: Config.activityList)
        for name in activityList! {
            let activity = Activity()
            activity.name = name
            labeling.activityList.append(activity)
        }
        labeling.period = self.defaults.integer(forKey: Config.period)
        let realm = try! Realm()
        try! realm.write {
            realm.add(labeling)
        }
    }
    
    @objc func labeling() {
        add()
        write()
    }
    
    func add() {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        let labeling = realm.object(ofType: Labeling.self, forPrimaryKey: self.id)
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
            labeling?.labels.append(label)
        }
    }
    
    func write() {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        var fields: [String: Int] = [:]
        for (name, value) in zip(activityList!, section.values()) {
            if let isOn = value as? Bool {
                fields[name] = isOn ? 1:0
            }
        }
        let database = defaults.string(forKey: Config.database)!
        let measurement = defaults.string(forKey: Config.measurement)!
        let host = defaults.string(forKey: Config.host)!
        let influxdb = InfluxDBClient(host: URL(string: host)!, databaseName: database)
        let request = WriteRequest(influxdb: influxdb, measurement: measurement, tags: [:], fields: fields)
        
        Session.send(request) { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        }
    }

}
