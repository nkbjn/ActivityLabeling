//
//  LabelingViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import APIKit
import ChameleonFramework


/// ラベリングをするViewController
class LabelingViewController: FormViewController {
    
    var labelingID: String? // ラベリングを保存するときのID
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    let activityList = UserDefaults.standard.stringArray(forKey: Config.activityList)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ロード時には行動が選択されていないため未選択にする
        self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
        self.title = "行動未選択"
        
        // ラベリング情報を作成
        self.labelingCreate()
        
        form
            +++ MultivaluedSection() {
                
                // 選択状態を取得するためにタグをつけておく
                $0.tag = Config.activityList
        
                // 行動の選択ボタンを作成する
                for activity in activityList! {
                    
                    $0 <<< SwitchRow {
                        $0.tag = activity
                        $0.title = activity
                        $0.value = false
                        
                    }.onChange{row in
                        
                        // 選択状態をはっきりさせるために背景色を変える
                        row.cell.backgroundColor = row.value! ? UIColor.flatWhiteDark : UIColor.white
                        
                        // 選択状態をデータベースに送信する
                        self.labelSend(tag: row.tag!)
                        
                    }.cellSetup() {cell, row in
                        // Chameleonで自動で変えられる色が合わないので変更
                        cell.switchControl.onTintColor = UIColor.flatGreen
                        
                    }
                    
                }
                
            }
        
            +++ Section()
            
                <<< ButtonRow() {
                    $0.title = "ラベリング終了"
                    
                }.onCellSelection { _, _ in
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
    }
    
    
    /// 行動が選択されているかどうかを判定する関数
    ///
    /// - Returns: 行動が一つでも選択されているかどうか
    func selectedCheck() -> Bool {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        
        for value in section.values() {
            if let isOn = value as? Bool {
                if isOn {
                    return true
                }
            }
        }
        
        return false
    }
    
    
    /// Realmにラベリングデータを作成する関数
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
    ///   - on: 追加する行動の状態
    func labelAdd(activity:String, status:Bool) {
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
    /// - Parameter tag: 選択した行動スイッチのタグ
    func labelSend(tag:String) {
        let row = form.rowBy(tag: tag) as! SwitchRow
        
        // 行動スイッチのタイトルが行動名
        let activity = row.title!
        
        // 行動スイッチの状態
        let status = row.value!
        
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
                // 通信成功したらRealmにも保存する
                self.labelAdd(activity: activity, status: status)
                
                // 通信成功したらステータスを成功に変える
                self.navigationController?.navigationBar.barTintColor = UIColor.flatMintDark
                self.title = "通信成功"
                
                // もし行動が選択されていなければステータスを未選択に変える
                if !self.selectedCheck() {
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
                    self.title = "行動未選択"
                }
                
            case .failure:
                // 通信に失敗したら行動スイッチを元に戻す
                row.value = status ? false:true
                
                // 通信に失敗したらステータスを通信失敗に変える
                self.navigationController?.navigationBar.barTintColor = UIColor.flatRed
                self.title = "通信失敗"
            }
        }
    }

}
