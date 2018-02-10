//
//  Label.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class Label: Object {
    @objc dynamic var time = Date()
    let activities = List<Activity>()
}

class Activity: Object {
    @objc dynamic var activity = ""
}
