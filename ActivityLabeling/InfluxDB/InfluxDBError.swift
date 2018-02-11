//
//  InfluxDBError.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/12.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

public struct InfluxDBError: Error {
    public let message: String
    
    public init(object: Any) {
        let dic = object as? [String: Any]
        self.message = dic?["error"] as? String ?? "unknown error"
    }
}
