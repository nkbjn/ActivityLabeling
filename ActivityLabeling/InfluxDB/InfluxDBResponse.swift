//
//  InfluxDBResponse.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/12.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

enum InfluxDBResponse {
    case noContent
    case results([Any])
    case unknown(Any)
}
