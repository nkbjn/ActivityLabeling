//
//  InfluxDBClient.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import Foundation
import APIKit

open class InfluxDBClient {
    public typealias Tags = [String: String]
    public typealias Fields = [String: Any]
    
    public let host: URL
    public let user: String?
    public let password: String?
    public let database: String?
    
    public init(host: URL, user: String? = nil, password: String? = nil, database: String? = nil) {
        self.host = host
        self.user = user
        self.password = password
        self.database = database
    }
    
}
