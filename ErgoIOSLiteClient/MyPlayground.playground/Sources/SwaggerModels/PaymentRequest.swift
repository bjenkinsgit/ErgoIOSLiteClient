//
//  PaymentRequest.swift
//  BioMetric1
//
//  Created by Bart Jenkins on 12/26/19.
//  Copyright © 2019 Bart Jenkins. All rights reserved.
//

import Foundation

public struct PaymentRequest: Codable {


    public var address: String

    /** Payment amount */
    public var value: Int64

    /** Assets list in the transaction */
    public var assets: [Asset]?

    public var registers: Registers?
    public init(address: String, value: Int64, assets: [Asset]? = nil, registers: Registers? = nil) {
        self.address = address
        self.value = value
        self.assets = assets
        self.registers = registers
    }

}
