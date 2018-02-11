//
//  QueryRequest.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/12.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import APIKit

class QueryRequest: InfluxDBRequest {
    let influxdb: InfluxDBClient
    
    let query: String
    let database: String?
    
    init(influxdb: InfluxDBClient, query: String, database: String? = nil) {
        self.influxdb = influxdb
        self.query = query
        self.database = database
    }
    
    var method = HTTPMethod.post
    var path = "/query"
    
    var queryParameters: [String: Any]? {
        if self.database != nil {
            return ["q": self.query, "db": self.database!]
        } else {
            return ["q": self.query]
        }
    }
}
