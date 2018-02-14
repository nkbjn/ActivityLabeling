//
//  DefaultConfig.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/10.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import Foundation


/// 基本設定を読み込む
class DefaultConfig {
    
    let defaults = UserDefaults.standard
    
    
    /// DefaultConfig.plistの設定を読み込む
    func setup() {
        if let path = Bundle.main.path(forResource: "DefaultConfig", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                defaults.register(defaults: dict as! [String : Any])
            }
        }
    }
    
    
    /// 変更した設定を元に戻す
    func reset() {
        let appDomain = Bundle.main.bundleIdentifier
        defaults.removePersistentDomain(forName: appDomain!)
        setup()
    }
    
}
