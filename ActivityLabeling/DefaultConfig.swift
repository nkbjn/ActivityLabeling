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
    
    
    /// Defaultに設定
    func setup() {
        // KeyChainの初期化
        if Keychain.user.value() == nil {
            Keychain.user.set("")
        }
        if Keychain.password.value() == nil {
            Keychain.password.set("")
        }
        // DefaultConfigの設定を読み込む
        if let path = Bundle.main.path(forResource: "DefaultConfig", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                defaults.register(defaults: dict as! [String : Any])
            }
        }
    }
    
    
    /// 変更した設定を元に戻す
    func reset() {
        Keychain.user.set("")
        Keychain.password.set("")
        let appDomain = Bundle.main.bundleIdentifier
        defaults.removePersistentDomain(forName: appDomain!)
        setup()
    }
    
}
