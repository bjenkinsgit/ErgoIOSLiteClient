//
//  UserSettings.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/29/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var defaults = UserDefaults.standard
    @Published var account = Account()
    @Published var isAuthenticated = false
    @Published var networkMonitoringStarted = false
    @Published var selectedAccountIndex = 0
    @Published var lastKnownNumberOfAccounts = 0
    @Published var fullHeightVal = UInt64(0)
    @Published var headersHeightVal = UInt64(0)
    @Published var progressBarValue: CGFloat = 0
    @Published var paymentsPayees = [PaymentsPayee]()
    @Published var currentPayee = ""
    
    var description: String {
        return "fullHeightVal=\(self.fullHeightVal), headersHeightVal=\(self.headersHeightVal)"
    }
    
    func createPaymentsPayee(name: String, p2pk: String) -> PaymentsPayee {
        return PaymentsPayee(payeeNameIn: name, payeeP2PKin: p2pk)
    }
}

class PaymentsPayee {
    var payeeName: String = ""
    var payeeP2PK: String = ""
    
    init(payeeNameIn: String, payeeP2PKin: String) {
        payeeName = payeeNameIn
        payeeP2PK = payeeP2PKin
    }
    
    init() {}
}



