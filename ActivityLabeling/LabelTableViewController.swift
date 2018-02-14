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
    var labelingID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベル"
        tableView.allowsSelection = false
        
        let labeling = realm.object(ofType: Labeling.self, forPrimaryKey: labelingID)
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
        
        cell.detailTextLabel?.text = "\(label.activity):\(label.status ? "on":"off")"
        
        return cell
    }
    
}

