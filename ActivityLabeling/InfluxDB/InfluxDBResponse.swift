//
//  InfluxDBResponse.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/12.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

enum InfluxDBResponse {
    case noContent
    case results(InfluxDB)
    case unknown(Any)
}


struct InfluxDB: Codable {
    var results: [Result]?
    
    struct Result: Codable {
        var statementId: Int
        var error: String?
        var series: [Series]?
        
        private enum CodingKeys: String, CodingKey {
            case statementId = "statement_id"
            case series
        }
    }
}

struct Series: Codable {
    var name: String
    var columns: [String]
    var values: [[StringOrIntType]]
}

enum StringOrIntType: Codable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .string(container.decode(String.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .int(container.decode(Int.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(StringOrIntType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        }
    }
    
    /// InfluxDBから取得したデータを文字列に変換
    ///
    /// - Parameter arg: Field値
    /// - Returns: Field値の文字列
    func string() -> String {
        switch self {
        case let .string(str):
            return str
        case let .int(int):
            return String(int)
        }
    }
}
