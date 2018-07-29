//
//  KeyChain.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/07/24.
//  Copyright © 2018 Wataru Sasaki. All rights reserved.
//

import Foundation
import Security

public enum Keychain: String {
    // キー名
    case user = "user"
    case password = "password"
    
    
    // データの保存
    public func set(_ value: String) {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.rawValue as AnyObject,
            kSecValueData as String: value.data(using: .utf8)! as AnyObject
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    // データの取り出し
    public func value() -> String? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.rawValue as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == noErr else {
            return nil
        }
        guard let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
