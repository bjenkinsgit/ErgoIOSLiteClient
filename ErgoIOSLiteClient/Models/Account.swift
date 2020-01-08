//
//  Account.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/8/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI
import Combine

final class Account : ObservableObject
 {
  @Published var accountSettingsChanged = false
  @Published var authkey = "" {
      didSet {
          accountSettingsChanged = true
      }
  }
  @Published var authKeyOrig = "" 
  @Published var authKeyPwd = "" {
      didSet {
          accountSettingsChanged = true
      }
  }
  @Published var authKeyPwdOrig = ""
  @Published var ergoApiUrl = "" {
      didSet {
          accountSettingsChanged = true
      }
  }
  @Published var ergoApiUrlOrig = ""

}
