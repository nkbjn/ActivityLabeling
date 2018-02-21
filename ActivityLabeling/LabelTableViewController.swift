//
//  LabelTableViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import RealmSwift


/// 過去のラベリングの詳細を表示するTableViewController
class LabelTableViewController: UITableViewController {

    lazy var realm = try! Realm()
    var labels: List<Label>!
    var id: String?
    let activityDict = UserDefaults.standard.dictionary(forKey: Config.activityDict)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ラベル"
        tableView.allowsSelection = false
        
        let labeling = realm.object(ofType: Labeling.self, forPrimaryKey: id)
        labels = labeling?.labels
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let label = labels[indexPath.row]
        
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        cell.textLabel?.text = f.string(from: label.time)
        
        let activity = activityDict[label.activity] as! String
        cell.detailTextLabel?.text = "\(activity):\(label.status ? "開始":"終了")"
        
        return cell
    }
    
}

