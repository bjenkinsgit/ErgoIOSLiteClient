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
    
  @Published var accountSettingsChanged = false 

  @Published var accountName = "" {
        didSet {
            if (isLoaded) {
               accountSettingsChanged = true
            }
        }
  }
  @Published var accountNameOrig = ""
  var halfAuthKey: String = ""
    
  @Published var authkey = "" {
      didSet {
          if (isLoaded) {
             accountSettingsChanged = true
          }
        if (authkey.count > 32) {
            halfAuthKey = String(authkey.dropLast(32))
        } else {
            halfAuthKey = authkey
        }
      }
  }
  @Published var authKeyOrig = "" 

  @Published var authKeyPwd = "" {
      didSet {
          if (isLoaded) {
             accountSettingsChanged = true
          }
      }
  }
  @Published var authKeyPwdOrig = ""
    
  @Published var ergoApiUrl = "" {
      didSet {
          if (isLoaded) {
             accountSettingsChanged = true
          }
      }
  }
  @Published var ergoApiUrlOrig = ""

}
