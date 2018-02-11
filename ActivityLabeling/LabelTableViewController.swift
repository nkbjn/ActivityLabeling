//
//  LabelTableViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class LabelTableViewController: UITableViewController {

    lazy var realm = try! Realm()
    var labels: Results<Label>!
    var selectedID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベル"
        
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
        
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        cell.textLabel?.text = f.string(from: label.time)
        
        cell.detailTextLabel?.text = label.activities.reduce("activity:") { (result, activity) in
            return result + " " + activity.name
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let label = labels[indexPath.row]
        selectedID = label.id
        performSegue(withIdentifier: "", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            
        }
    }
    
}

