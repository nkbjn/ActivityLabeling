//
//  InfluxDBRequest.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import APIKit

protocol InfluxDBRequest: Request where Response == InfluxDBResponse  {
    var influxdb: InfluxDBClient { get }
}

final class DecodableDataParser: DataParser {
    var contentType: String? {
        return "application/json"
    }
    
    func parse(data: Data) throws -> Any {
        return data
    }
}

extension InfluxDBRequest {
    
    var baseURL: URL {
        let host = self.influxdb.host
        let port = String(describing: self.influxdb.port)
        let urlProtocol = self.influxdb.ssl ? "https": "http"
        return URL(string: "\(urlProtocol)://\(host):\(port)")!
    }
    
    var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
        
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
}

