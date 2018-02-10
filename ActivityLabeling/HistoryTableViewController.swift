//
//  HistoryTableViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryTableViewController: UITableViewController {
    
    lazy var realm = try! Realm()
    var labels: Results<Label>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "履歴"
        
        labels = realm.objects(Label.self)

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
        
        cell.textLabel?.text = label.activities.reduce(""){(result, label) in
            return result + label.activity
        }
        
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        cell.detailTextLabel?.text = f.string(from: label.time)
        
        return cell
    }

}
