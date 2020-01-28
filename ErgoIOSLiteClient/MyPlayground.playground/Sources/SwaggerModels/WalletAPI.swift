//
//  WalletAPI.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/5/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import Foundation

public struct WalletUnlockRequest : Codable {
    public var pass: String
}

public struct WalletStatus : Codable {
    public var isInitialized : Bool
    public var isUnlocked : Bool
}
