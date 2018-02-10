//
//  DefaultConfig.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import Foundation

class DefaultConfig {
    
    let defaults = UserDefaults.standard
    
    func reset() {
        let appDomain = Bundle.main.bundleIdentifier
        defaults.removePersistentDomain(forName: appDomain!)
        setup()
    }
    
    func setup() {
        if let path = Bundle.main.path(forResource: "DefaultConfig", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                defaults.register(defaults: dict as! [String : Any])
            }
        }
    }
    
}
