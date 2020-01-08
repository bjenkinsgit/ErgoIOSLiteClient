//
//  Account.swift
//  BioMetric1
//
//  Created by Bart Jenkins on 12/25/19.
//  Copyright © 2019 Bart Jenkins. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct AccountSettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var secureStoreWithGenericPwd: SecureStore!
    @State private var isUnlocked = false
    @State private var accountName = ""
    @State private var showingSaveSucessAlert = false
    @State private var showSaveButton = false
    @State private var showAuthKeyField = false
    @State private var showAuthKeyPwdField = false
    @State private var currLockClicked = 0 // 1 means authKey, 2 means authKeyPwd
    @ObservedObject private var keyboard = KeyboardResponder()
    @ObservedObject var account: Account

    var body: some View {
        let authKeyBinding = Binding<String>(get: {
            self.account.authkey
        }, set: {
            self.account.authkey = $0
            self.showSaveButton = (self.account.authkey != self.account.authKeyOrig ||
                self.account.authKeyPwd != self.account.authKeyPwdOrig)
        })
        let authKeyPwdBinding = Binding<String>(get: {
            self.account.authKeyPwd
        }, set: {
            self.account.authKeyPwd = $0
            self.showSaveButton = (self.account.authkey != self.account.authKeyOrig ||
                self.account.authKeyPwd != self.account.authKeyPwdOrig)
        })
        let urlTextFieldBinding = Binding<String>(get: {
            self.account.ergoApiUrl
        }, set: {
            self.account.ergoApiUrl = $0
            self.showSaveButton = (self.account.ergoApiUrl != self.account.ergoApiUrlOrig)
        })

        return NavigationView {
         Form {
            Section {
                  Text("Account Name:")
                  TextField("e.g. My main ergo node", text: $accountName)
            }
          Section {
            Text("Authorization Key:")
            HStack {
                Image(systemName: "lock")
                .foregroundColor(.secondary)
                if showAuthKeyField {
                    TextField("e.g. abcd1234...",
                    text: authKeyBinding)
                } else {
                   SecureField("e.g. abcd1234...", text: authKeyBinding)
                }
                Button(action: {
                    self.currLockClicked = 1
                    self.authenticate()
                }) {
                    Image(systemName: "eye")
                    .foregroundColor(.secondary)
                }
            }
          }
          Section {
            Text("Authorization Key Password:")
            HStack {
             Image(systemName: "lock")
             .foregroundColor(.secondary)
                if showAuthKeyPwdField {
                    TextField("e.g. my_secret_password",
                    text: authKeyPwdBinding)
                } else {
                  SecureField("e.g. my_secret_password", text: authKeyPwdBinding)
                }
                Button(action: {
                    self.currLockClicked = 2
                    self.authenticate()
                }) {
                    Image(systemName: "eye")
                    .foregroundColor(.secondary)
                }
            }
          }
            Section {
                Text("ERGO Node Url:")
                TextField("e.g. http://your.private.vpn.ergo.node:9052", text: urlTextFieldBinding)
            }
           if (showSaveButton) {
              HStack {
              Button(action: {
                    let retval = self.saveAuthData()
                    if (retval) {
                        self.showingSaveSucessAlert.toggle()
                        
                }
                
                    
                }) {
                    Text("SAVE CHANGES")
                }
            } // HStack
           }

         }.navigationBarTitle("ACCOUNT", displayMode: .inline)
            .alert(isPresented: $showingSaveSucessAlert) {
                Alert(title: Text("Keychain Updated"), message: Text("AUTH DATA STORED SECURELY IN KEYCHAIN!"), dismissButton: .default(Text("OK"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
        }.onAppear(perform: initForm)
         .navigationViewStyle(StackNavigationViewStyle())  
        .padding(.bottom, keyboard.currentHeight)
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeOut(duration: 0.16))// Nav view
    }
    
    func authenticate() {
        if (self.showAuthKeyField || self.showAuthKeyPwdField) {
            if (self.showAuthKeyField && currLockClicked==1) {
              self.showAuthKeyField.toggle()
            }
                if (self.showAuthKeyPwdField && currLockClicked==2) {
                    self.showAuthKeyPwdField.toggle()
                }
            return
        }

         let context = LAContext()
         var error: NSError?

         // check whether biometric authentication is possible
         if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
             // it's possible, so go ahead and use it
             let reason = "We need to unlock your data."

             context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                 // authentication has now completed
                 DispatchQueue.main.async {
                     if success {
                        self.loadAuthData()
                        if (self.showAuthKeyField==false) {
                           self.showAuthKeyField.toggle()
                        }
                        if (self.showAuthKeyPwdField==false) {
                           self.showAuthKeyPwdField.toggle()
                        }
                     } else {
                         _ = Alert(title: Text("Important message"), message: Text("Authentication unsuccessful"), dismissButton: .default(Text("OK")))
                     }
                 }
             }
         } else {
             _ = Alert(title: Text("Important message"), message: Text("Biometric Authentication not available"), dismissButton: .default(Text("OK")))
         }
     }
    
    func loadAuthData() {
        do {
            self.account.authkey = try (secureStoreWithGenericPwd.getValue(for: "authkey") ?? "")
            self.account.authKeyOrig = self.account.authkey
            self.account.authKeyPwd = try (secureStoreWithGenericPwd.getValue(for: "authKeyPwd") ?? "")
            self.account.authKeyPwdOrig = self.account.authKeyPwd
            self.account.ergoApiUrl = try (secureStoreWithGenericPwd.getValue(for: "ergoApiUrl") ?? "")
            self.account.ergoApiUrlOrig = self.account.ergoApiUrl
//            showSendTo = (authkey.count>0 && authKeyPwd.count>0 && ergoApiUrl.count>0)
        } catch (let e) {
          print("EXCEPTION: Loading authkey and authKeyPwd failed with \(e.localizedDescription).")
        }
    }

    func initForm() {
         let genericPwdQueryable = GenericPasswordQueryable(service: "56F7835N8P.com.amc.ergo.client1")
         secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        self.loadAuthData()
     }

    
    func saveAuthData()-> Bool {
      do {
            try secureStoreWithGenericPwd.setValue(self.account.authkey, for: "authkey")
            try secureStoreWithGenericPwd.setValue(self.account.authKeyPwd, for: "authKeyPwd")
            try secureStoreWithGenericPwd.setValue(self.account.ergoApiUrl, for: "ergoApiUrl")
            return true
      } catch (let e) {
        print("EXCEPTION: Saving authkey and authKeyPwd failed with \(e.localizedDescription).")
        return false
      }
    }

}



struct Account_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(account: Account())
    }
}
