//
//  InfluxDBRequest.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import APIKit

protocol InfluxDBRequest: Request where Response == InfluxDBResponse {
    var influxdb: InfluxDBClient { get }
}

extension InfluxDBRequest {
    
    var baseURL: URL {
        let host = self.influxdb.host
        let port = String(describing: self.influxdb.port)
        let urlProtocol = self.influxdb.ssl ? "https": "http"
        return URL(string: "\(urlProtocol)://\(host):\(port)")!
    }
    
    // 異常終了時はJSONが返ってくるので、InfluxDBErrorでパースさせる
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard (200..<300).contains(urlResponse.statusCode) else {
            print(urlResponse)
            print(object)
            throw InfluxDBError.init(object: object)
        }
        return object
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard (200..<300).contains(urlResponse.statusCode) else {
            print(urlResponse)
            print(object)
            throw InfluxDBError.init(object: object)
        }
        
        if urlResponse.statusCode == 204 {
            return .noContent
        }
        
        if let json = object as? [String: Any],
            let results = json["results"] as? [Any] {
            return .results(results)
        }
        return .unknown(object)
    }
}

