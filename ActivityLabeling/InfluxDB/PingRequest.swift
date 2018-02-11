//
//  PingRequest.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/12.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import APIKit

class PingRequest: InfluxDBRequest {
    let influxdb: InfluxDBClient
    
    init(influxdb: InfluxDBClient) {
        self.influxdb = influxdb
    }
    
    var method = HTTPMethod.get
    var path = "/ping"
    
}
