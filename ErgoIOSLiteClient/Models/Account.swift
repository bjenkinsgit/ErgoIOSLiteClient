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
  public var isLoaded = false
  var halfAuthKey: String = ""

  @Published var accountSettingsChanged = false 


    let debugAuthKey = ""
    let debugAuthKeyPwd = ""
    let debugErgoApiUrl = ""

    public init() {
        self.authkey = debugAuthKey
        self.authKeyPwd = debugAuthKeyPwd
        self.ergoApiUrl = debugErgoApiUrl
    }

    @Published var authkey =  "" {
      didSet {
        if (authkey.count > 32) {
            halfAuthKey = String(authkey.dropLast(32))
        } else {
            halfAuthKey = authkey
        }
      accountSettingsChanged = accountSettingsChanged || (self.authkey != "" && self.ergoApiUrl != "" && self.authKeyPwd != "")
      }
  }
//  @Published var authKeyOrig = ""

  @Published var authKeyPwd = "" {
      didSet {
        accountSettingsChanged = accountSettingsChanged || (self.authkey != "" && self.halfAuthKey != "" && self.ergoApiUrl != "")
      }
  }
//  @Published var authKeyPwdOrig = ""
    
  @Published var ergoApiUrl = "http://192.168.1.59:9052" {
      didSet {
        accountSettingsChanged = accountSettingsChanged || (self.authkey != "" && self.halfAuthKey != "" && self.authKeyPwd != "")
      }
  }
//  @Published var ergoApiUrlOrig = ""

}
