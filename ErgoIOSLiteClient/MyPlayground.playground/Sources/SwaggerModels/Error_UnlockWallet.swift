//
//  Error_UnlockWallet.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/22/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import Foundation
public struct PRPR: Codable {
    public var sendPR: PaymentRequest
    public var respPR: PaymentRequest
}

public struct  StrPR: Codable {
    public var errShortStr: String
    public var details: [PRPR]
    public var errLongStr: String
    public init(errShortStr: String, details: [PRPR], errLongStr: String) {
        self.errShortStr = errShortStr
        self.details = details
        self.errLongStr = errLongStr
    }
}

public struct Error_UnlockWallet: Codable {
    public var error: Int
    public var reason: String
    public var detail: StrPR
    public init(error: Int, reason: String, detail: StrPR) {
        self.error = error
        self.reason = reason
        self.detail = detail
    }
}
