//
//  ApiError.swift
//  BioMetric1
//
//  Created by Bart Jenkins on 12/31/19.
//  Copyright © 2019 Bart Jenkins. All rights reserved.
//

import Foundation

public struct ApiError: Codable {
    public var error: Int
    public var reason: String
    public var detail: String
    public init(error: Int, reason: String, detail: String) {
        self.error = error
        self.reason = reason
        self.detail = detail
    }
}

