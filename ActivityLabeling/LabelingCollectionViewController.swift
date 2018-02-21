//
//  LabelingViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/15.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import APIKit
import RealmSwift

private let reuseIdentifier = "Cell"

class LabelingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let realm = try! Realm()
    let activityDict = UserDefaults.standard.dictionary(forKey: Config.activityDict)!
    let database = UserDefaults.standard.string(forKey: Config.database)!
    let measurement = UserDefaults.standard.string(forKey: Config.measurement)!
    let host = UserDefaults.standard.string(forKey: Config.host)!
    let user = UserDefaults.standard.string(forKey: Config.user)!
    let password = UserDefaults.standard.string(forKey: Config.password)!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var id: String? // ラベリングを保存するときのID
    var selectedItems = [Int: Bool]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(UINib(nibName: "LabelingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createLabeling()
        changeStatus()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // 画面の向きが変わったらアイコンの大きさを更新する
        collectionView.reloadData()
    }
    
    /// 行動が選択されているかどうかを判定する
    ///
    /// - Returns: 行動が一つでも選択されているかどうか
    func selected() -> Bool {
        if selectedItems.isEmpty {
            return false
        }
        return true
    }
    
    
    /// 行動が選択されているかどうかを確認して、ステータスを変更する
    func changeStatus() {
        if selected() {
            // 行動が選択されていればステータスをノーマルに変える
            navigationController?.navigationBar.barTintColor = .flatBlack
            title = ""
        } else {
            // 行動が選択されていなければステータスを未選択に変える
            navigationController?.navigationBar.barTintColor = .flatRed
            title = "行動未選択"
        }
    }
    
    
    /// Realmにラベリングデータを作成する
    func createLabeling() {
        let labeling = Labeling()
        
        // 行動選択時にラベルデータを追加するために変数に代入しておく
        id = labeling.id
        
        labeling.host = host
        
        try! realm.write {
            realm.add(labeling)
        }
    }
    
    
    /// Realmのラベリングデータにラベルデータを追加する
    ///
    /// - Parameters:
    ///   - activity: 追加する行動
    ///   - status: 追加する行動の状態
    func addLabel(activity: String, status: Bool) {
        // ラベリングデータをIDから検索する
        let labeling = realm.object(ofType: Labeling.self, forPrimaryKey: id)
        
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
    func sendLabel(activity: String, status: Bool, handler: @escaping (Bool) -> ()) {
        
        var fields: [String: Any] = [:]
        fields["activity"] = activity
        fields["status"] = status ? 1:0
        
        let influxdb = InfluxDBClient(host: host, user: user, password: password)
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
        
        guard !selected() else {
            // 行動を選択している状態で終了しようとした場合
            let alert = UIAlertController(title: "エラー",
                                          message: "全ての行動を終了させてください",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
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
        present(alert, animated: true)
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = view.frame.height
        var cellSize: CGFloat = 0
        if width < height {
            cellSize = width / 5
        } else {
            cellSize = height / 5
        }
        return CGSize(width: cellSize, height: cellSize)
    }
    

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activityDict.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LabelingCollectionViewCell
    
        // Configure the cell
        let key = Array(activityDict.keys)[indexPath.row]
        let activity = activityDict[key] as! String
        cell.imageView.image = UIImage(named:"\(key)")?.withRenderingMode(.alwaysTemplate)
        cell.textLabel.text = activity
        
        if let _ = selectedItems[indexPath.row] {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.isSelected = true
            cell.iconView.backgroundColor = .flatSkyBlue
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            cell.isSelected = false
            cell.iconView.backgroundColor = .flatBlack
        }
    
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = Array(activityDict.keys)[indexPath.row]
        let activityName = activityDict[activity] as! String
        let status = cell.isSelected
        
        let massage = "\(activityName)を開始しますか？"
        let alert = UIAlertController(title: "行動開始", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開始", style: .default, handler: { action in
            self.sendLabel(activity: activity, status: status, handler: { response in
                if response {
                    // 通信成功したらRealmにも保存する
                    self.addLabel(activity: activity, status: status)
                    
                    self.selectedItems[indexPath.row] = true
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
        present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = Array(activityDict.keys)[indexPath.row]
        let activityName = activityDict[activity] as! String
        let status = cell.isSelected
        
        let massage = "\(activityName)を終了しますか？"
        let alert = UIAlertController(title: "行動終了", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "終了", style: .default, handler: { action in
            self.sendLabel(activity: activity, status: status, handler: { response in
                
                guard response else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                    return
                }
                
                // 通信成功したらRealmにも保存する
                self.addLabel(activity: activity, status: status)
                
                self.selectedItems.removeValue(forKey: indexPath.row)
                cell.iconView.backgroundColor = .flatBlack
                
                self.changeStatus()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }))
        present(alert, animated: true)
    }

}
