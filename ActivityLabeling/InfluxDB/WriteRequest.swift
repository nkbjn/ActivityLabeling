//
//  WriteRequest.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/12.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import APIKit

class WriteRequest: InfluxDBRequest {
    let influxdb: InfluxDBClient
    
    let measurement: String
    let tags: InfluxDBClient.Tags
    let fields: InfluxDBClient.Fields
    let time: TimeInterval?
    
    init(influxdb: InfluxDBClient,
         measurement: String,
         tags: InfluxDBClient.Tags,
         fields: InfluxDBClient.Fields,
         time: TimeInterval? = nil) {
        self.influxdb = influxdb
        self.measurement = measurement
        self.tags = tags
        self.fields = fields
        self.time = time
    }
    
    var method = HTTPMethod.post
    var path = "/write"
    
    var queryParameters: [String: Any]? {
        return ["db": self.influxdb.database]
    }
    
    var bodyParameters: BodyParameters? {
        return WriteParameters(request: self)
    }
    
    struct WriteParameters: BodyParameters {
        var request: WriteRequest
        
        var contentType: String { return "application/x-www-form-urlencoded" }
        
        var fieldsStr: String {
            return request.fields
                .map { key, value in
                    return "\(key)=\(value)"
                }
                .joined(separator: ",")
        }
        
        func buildEntity() throws -> RequestBodyEntity {
            let t_param = request.tags.map { "\($0)=\($1)" }
            let tim = (request.time != nil) ? " \(request.time!)" : ""
            
            let params = "\(([request.measurement] + t_param).joined(separator: ",")) \(fieldsStr)\(tim)"
            
            return RequestBodyEntity.data(params.data(using: String.Encoding.utf8)!)
        }
    }
}
