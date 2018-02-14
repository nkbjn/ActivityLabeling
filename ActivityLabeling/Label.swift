//
//  Label.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import RealmSwift


/// ラベリングのモデル
class Labeling: Object {
    
    @objc dynamic var id = NSUUID().uuidString  // ユニークID
    @objc dynamic var host = ""                 // データベースに接続するホスト名
    @objc dynamic var startTime = Date()        // ラベリング開始時間
    let labels = List<Label>()                  // ラベル群
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}


/// ラベルのモデル
class Label: Object {
    
    @objc dynamic var id = NSUUID().uuidString  // ユニークID
    @objc dynamic var time = Date()             // ラベリング時の時刻
    @objc dynamic var activity = ""             // 変更行動
    @objc dynamic var status = true                 // 変更後の状態
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
