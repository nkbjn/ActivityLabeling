//
//  Label.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class Labeling: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var host = ""
    @objc dynamic var startTime = Date()
    let labels = List<Label>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Label: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var time = Date()
    @objc dynamic var activity = ""
    @objc dynamic var on = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
