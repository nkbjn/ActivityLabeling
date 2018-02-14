//
//  HistoryTableViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import RealmSwift


/// ラベリングの履歴を表示するTableViewController
class HistoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var labelings: Results<Labeling>!   // ラベリング履歴
    var selectedID: String?             // 選択したラベリングID

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "履歴"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // ラベリング時間で降順にソートする
        labelings = realm.objects(Labeling.self).sorted(byKeyPath: "startTime", ascending: false)
        
        // タブ切り替え時に再読み込みされるようにする
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
        
        // メインはラベリング開始時間
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        cell.textLabel?.text = "\(f.string(from: labeling.startTime)) 〜"
        
        // 詳細は接続ホスト
        cell.detailTextLabel?.text = "\(labeling.host)"
        
        // タッチできることをわかりやすくする
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択したラベリングのIDを取得する
        let labeling = labelings[indexPath.row]
        selectedID = labeling.id
        
        // LabelTableViewControllerに遷移
        performSegue(withIdentifier: "LabelTableViewControllerSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LabelTableViewControllerSegue" {
            // どの履歴をタップしたのかを保存する
            let vc = segue.destination as! LabelTableViewController
            vc.labelingID = selectedID
        }
    }

}
