//
//  LabelingCollectionViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/15.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import APIKit
import RealmSwift

private let reuseIdentifier = "Cell"

class LabelingCollectionViewController: UICollectionViewController {
    
    var labelingID: String? // ラベリングを保存するときのID
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    let activityDict = UserDefaults.standard.dictionary(forKey: Config.activityDict)!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UINib(nibName: "LabelingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.allowsMultipleSelection = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // ラベリング情報を作成
        self.labelingCreate()
        
        // ラベリング開始時には行動未選択状態にする
        self.changeStatus()
    }
    
    /// 行動が選択されているかどうかを判定する
    ///
    /// - Returns: 行動が一つでも選択されているかどうか
    func selectedCheck() -> Bool {
        if let selectedItems = self.collectionView?.indexPathsForSelectedItems {
            if !selectedItems.isEmpty {
                return true
            }
        }
        return false
    }
    
    
    /// 行動が選択されているかどうかを確認して、ステータスを変更する
    func changeStatus() {
        // もし行動が選択されていなければステータスを未選択に変える
        if !self.selectedCheck() {
            self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
            self.title = "行動未選択"
        } else {
            self.navigationController?.navigationBar.barTintColor = UIColor.flatBlack
            self.title = ""
        }
    }
    
    
    /// Realmにラベリングデータを作成する
    func labelingCreate() {
        let labeling = Labeling()
        
        // 行動選択時にラベルデータを追加するために変数に代入しておく
        self.labelingID = labeling.id
        
        labeling.host = self.defaults.string(forKey: Config.host)!
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(labeling)
        }
    }
    
    
    /// Realmのラベリングデータにラベルデータを追加する
    ///
    /// - Parameters:
    ///   - activity: 追加する行動
    ///   - status: 追加する行動の状態
    func labelAdd(activity: String, status: Bool) {
        // ラベリングデータをIDから検索する
        let labeling = realm.object(ofType: Labeling.self, forPrimaryKey: self.labelingID)
        
        let label = Label()
        label.activity = activity
        label.status = status
        
        try! realm.write {
            labeling?.labels.append(label)
        }
    }
    
    
    /// DBサーバにラベルデータを送信する
    ///
    /// - Parameters:
    ///   - activity: 行動
    ///   - status: 行動の状態
    ///   - handler: 送信結果を返却する
    func labelSend(activity: String, status: Bool, handler: @escaping (Bool) -> ()) {
        
        var fields: [String: Any] = [:]
        fields["activity"] = activity
        fields["status"] = status ? 1:0
        
        let database = defaults.string(forKey: Config.database)!
        let measurement = defaults.string(forKey: Config.measurement)!
        let host = defaults.string(forKey: Config.host)!
        let influxdb = InfluxDBClient(host: URL(string: host)!)
        let request = WriteRequest(influxdb: influxdb, database: database, measurement: measurement, tags: [:], fields: fields)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(true)
                
            case .failure:
                handler(false)
                let alert = UIAlertController(title: "通信エラー", message: "通信に失敗しました", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    /// 終了ボタンを押した時の処理
    @IBAction func exit(_ sender: Any) {
        // 行動を選択している状態で終了されると困るのでチェック
        if self.selectedCheck() {
            let alert = UIAlertController(title: "エラー",
                                          message: "全ての行動を終了させてください",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // 誤って終了してしまうのを防ぐためにアラートを表示
        let alert = UIAlertController(title: "ラベリング終了",
                                      message: "本当に終了してよろしいですか？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "終了",
                                      style: .default,
                                      handler: { action in
                                        self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activityDict.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LabelingCollectionViewCell
    
        // Configure the cell
        let key = Array(activityDict.keys)[indexPath.row]
        let activity = activityDict[key] as! String
        cell.imageView.image = UIImage(named:"\(key)")?.withRenderingMode(.alwaysTemplate)
        cell.textLabel.text = activity
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = Array(activityDict.keys)[indexPath.row]
        let activityName = activityDict[activity] as! String
        let status = cell.isSelected
        
        let massage = "\(activityName)を開始しますか？"
        let alert = UIAlertController(title: "行動開始", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開始", style: .default, handler: { action in
            self.labelSend(activity: activity, status: status, handler: { response in
                if response {
                    // 通信成功したらRealmにも保存する
                    self.labelAdd(activity: activity, status: status)
                    
                    cell.iconView.backgroundColor = .flatSkyBlue
                    self.changeStatus()
                } else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.deselectItem(at: indexPath, animated: true)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = Array(activityDict.keys)[indexPath.row]
        let activityName = activityDict[activity] as! String
        let status = cell.isSelected
        
        let massage = "\(activityName)を終了しますか？"
        let alert = UIAlertController(title: "行動終了", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "終了", style: .default, handler: { action in
            self.labelSend(activity: activity, status: status, handler: { response in
                if response {
                    // 通信成功したらRealmにも保存する
                    self.labelAdd(activity: activity, status: status)
                    
                    cell.iconView.backgroundColor = .flatBlack
                    
                    self.changeStatus()
                } else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }))
        self.present(alert, animated: true)
    }

}
