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
    
    public let host: String
    public let port: Int
    public let user: String?
    public let password: String?
    public let ssl: Bool
    
    public init(host: String, port: Int = 8086, user: String? = nil, password: String? = nil, ssl: Bool = false) {
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.ssl = ssl
    }
    
}
