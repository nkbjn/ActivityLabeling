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
    
    var labelList = [[String: Any]()]

    let api = APIManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
    }
    
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
    
    func convertString(arg: StringOrIntType) -> String {
        switch arg {
        case let .string(str):
            return str
        case let .int(int):
            return String(int)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let dict = self.labelList[indexPath.row]
        
        if let time = dict["time"] as? StringOrIntType {
            let timeStr = convertString(arg: time)
            
            if let timeInterval = TimeInterval(timeStr) {
                let date = Date(timeIntervalSince1970: timeInterval)
                let f = DateFormatter()
                f.timeStyle = .medium
                f.dateStyle = .medium
                f.locale = Locale(identifier: "ja_JP")
                cell.textLabel?.text = f.string(from: date).description
            }
        }
        
        if let activity = dict["activity"] as? StringOrIntType,
            let status = dict["status"] as? StringOrIntType {
            let activityStr = convertString(arg: activity)
            let statusStr = convertString(arg: status) == "1" ? "Start": "Finish"
            cell.detailTextLabel?.text = "\(activityStr)：\(statusStr)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.labelList[indexPath.row]
        
        guard let time = dict["time"] as? StringOrIntType else {
            return
        }
        guard let activity = dict["activity"] as? StringOrIntType else {
            return
        }
        guard let status = dict["status"] as? StringOrIntType else {
            return
        }
        let timeStr = convertString(arg: time)
        let activityStr = convertString(arg: activity)
        let statusStr = convertString(arg: status)
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
