//
//  HistoryTableViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import APIKit

/// ラベリングの履歴を表示するTableViewController
class HistoryTableViewController: UITableViewController {
    
    let api = APIManager.shared
    var labelList = [[String: Any]()]
    
    
    /// テーブルビューに表示されている内容を再読み込みする
    func reload() {
        self.labelList.removeAll()
        self.tableView.reloadData()
        
        self.api.select(handler: { list, error in
            
            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            self.labelList = list!.reversed()
            self.tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reload()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.labelList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let dict = self.labelList[indexPath.row]
        
        guard let time = dict["time"] as? StringOrIntType,
            let activity = dict["activity"] as? StringOrIntType,
            let status = dict["status"] as? StringOrIntType else {
            return cell
        }
        
        let timeStr = time.string()
        if let timeInterval = TimeInterval(timeStr) {
            let date = Date(timeIntervalSince1970: timeInterval)
            let f = DateFormatter()
            f.timeStyle = .medium
            f.dateStyle = .medium
            f.locale = Locale(identifier: "ja_JP")
            cell.textLabel?.text = f.string(from: date).description
        }
        
        let activityStr = activity.string()
        let statusStr = status.string()
        cell.detailTextLabel?.text = "\(activityStr)：\(statusStr == "1" ? "Start": "Finish")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.labelList[indexPath.row]
        
        guard let time = dict["time"] as? StringOrIntType,
            let activity = dict["activity"] as? StringOrIntType,
            let status = dict["status"] as? StringOrIntType else {
                let alert = UIAlertController(title: "Error", message: "Value error.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            return
        }
        
        let timeStr = time.string()
        let activityStr = activity.string()
        let statusStr = status.string()
        let massage = "Would you like to delete \(activityStr):\(statusStr == "1" ? "Start": "Finish")?"
        let alert = UIAlertController(title: "Delete Label", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            self.api.delete(time: timeStr, handler: { error in
                
                guard (error == nil) else {
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                self.reload()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}
