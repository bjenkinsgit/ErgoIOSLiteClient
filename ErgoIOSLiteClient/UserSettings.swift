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
    @Published var fullHeightVal = UInt64(0)
    @Published var headersHeightVal = UInt64(0)
    @Published var progressBarValue: CGFloat = 0
    
    var description: String {
        return "fullHeightVal=\(self.fullHeightVal), headersHeightVal=\(self.headersHeightVal)"
    }
}
