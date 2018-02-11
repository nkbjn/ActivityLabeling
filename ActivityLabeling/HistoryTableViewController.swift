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
    var labelings: Results<Labeling>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "履歴"
        
        labelings = realm.objects(Labeling.self)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let labeling = labelings[indexPath.row]
        
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        cell.textLabel?.text = f.string(from: labeling.startTime)
        
        cell.detailTextLabel?.text = labeling.activityList.reduce(""){(result, activity) in
            return result + ", " + activity.name
        }
        
        return cell
    }

}
