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
    
    let realm = try! Realm()
    var labelings: Results<Labeling>!
    var selectedID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "履歴"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        labelings = realm.objects(Labeling.self).sorted(byKeyPath: "startTime", ascending: false)
        tableView.reloadData()
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
        cell.textLabel?.text = "\(f.string(from: labeling.startTime)) 〜"
        
        cell.detailTextLabel?.text = "\(labeling.host)"
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let labeling = labelings[indexPath.row]
        selectedID = labeling.id
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "LabelTableViewControllerSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LabelTableViewControllerSegue" {
            let vc = segue.destination as! LabelTableViewController
            vc.selectedID = selectedID
        }
    }

}
