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
    
    var selectedID: String?             // 選択したラベリングID
    var labelList = [[String: Any]()]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "履歴"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.labelList.removeAll()
        self.tableView.reloadData()
        
        if let user = Keychain.user.value(),
            let password = Keychain.password.value() {
            
            let database = UserDefaults.standard.string(forKey: Config.database)!
            let ssl = UserDefaults.standard.bool(forKey: Config.ssl)
            let host = UserDefaults.standard.string(forKey: Config.host)!
            let port = UserDefaults.standard.integer(forKey: Config.port)
            
            let query = "SELECT * FROM label WHERE \"user\"='\(user)'"
            let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
            let request = QueryRequest(influxdb: influxdb, query: query, database: database)
            
            Session.send(request) { result in
                switch result {
                case let .success(.results(value)):
                    if let results = value.results {
                        for result in results {
                            if let series = result.series {
                                for s in series {
                                    for v in s.values {
                                        self.labelList.append(zip(s.columns, v).reduce(into: [String: Any]()) { $0[$1.0] = $1.1 })
                                    }
                                }
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                case .success(.noContent):
                    break
                case .success(.unknown(_)):
                    break
                    
                case .failure(let error):
                    let alert = UIAlertController(title: "通信エラー", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                }
            }
            
        }
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
        
        if let activity = dict["activity"] as? StringOrIntType,
            let status = dict["status"] as? StringOrIntType {
            let activityStr = convertString(arg: activity)
            let statusStr = convertString(arg: status) == "1" ? "Start": "End"
            cell.textLabel?.text = "\(activityStr)：\(statusStr)"
        }
        
        if let time = dict["time"] as? StringOrIntType {
            cell.detailTextLabel?.text = convertString(arg: time)
        }
        
        return cell
    }

}
