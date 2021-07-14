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
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var account_E: Account_E
    @State var secureStoreWithGenericPwd: SecureStore!
    @State private var isUnlocked = false
    @State private var showingSaveSucessAlert = false
    @State private var showAuthKeyField = false
    @State private var showAuthKeyPwdField = false
    @State private var currLockClicked = 0 // 1 means authKey, 2 means authKeyPwd
//    @ObservedObject private var keyboard = KeyboardResponder()
//    @ObservedObject var account: Account
    @State var account: Account
    @State private var accountName = ""
    @State private var authKeyString : String = ""
    @State private var authKeyPasswordString: String = ""
    @State private var ergoNodeUrlString: String = "http://192.168.1.x:9053"
    @FetchRequest(entity: Account_E.entity(), sortDescriptors: []) var accounts : FetchedResults<Account_E>

    @State private var url = ""
    
    var body: some View {
        
    let nameBinding = Binding<String>(get: {
        //self.account_E.name ?? ""
        self.accountName
    }, set: {
        //self.account_E.name = $0
        self.accountName = $0
    })
    let authKeyBinding = Binding<String>(get: {
        self.authKeyString
    }, set: {
        self.authKeyString = $0
    })
    let passwordBinding = Binding<String>(get: {
        self.authKeyPasswordString
    }, set: {
        self.authKeyPasswordString = $0
    })
    let urlBinding = Binding<String>(get: {
        self.ergoNodeUrlString
    }, set: {
        self.ergoNodeUrlString = $0
        })

    return NavigationView {
//         Form {
        ScrollView {
          VStack(alignment: .leading) {
              Text("Account Name:")
              TextField("e.g. My main ergo node", text: nameBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
          }
            Divider().accentColor(Color.red)
          VStack(alignment: .leading)  {
            Text("Authorization Key:")
            HStack {
                Image(systemName: "lock")
                .foregroundColor(.secondary)
                if showAuthKeyField {
                    TextField("e.g. abcd1234...",
                        text: authKeyBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                } else {
                   SecureField("e.g. abcd1234...", text: authKeyBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                    .textContentType(.unspecified)
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
            Divider().accentColor(Color.red)
          VStack(alignment: .leading) {
            Text("Authorization Key Password:")
            HStack {
             Image(systemName: "lock")
             .foregroundColor(.secondary)
                if showAuthKeyPwdField {
                    TextField("e.g. your_secret_password",
                    text: passwordBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                } else {
                  SecureField("e.g. your_secret_password", text: passwordBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                    .textContentType(.unspecified)
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
            Divider().accentColor(Color.red)
            VStack(alignment: .leading) {
                Text("ERGO Node Url:")
                TextField("e.g. http://your.ergo.node:9052", text: urlBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
            }.KeyboardAwarePadding()
            Divider().accentColor(Color.red)
              Button(action: saveAuthData) {
                    Text("SAVE CHANGES")
              }.disabled(formNotYetFilled()) // HStack
           

         } // scroll view
         .navigationBarTitle("ACCOUNT", displayMode: .inline)
            .alert(isPresented: $showingSaveSucessAlert) {
                Alert(title: Text("Keychain Updated"), message: Text("AUTH DATA STORED SECURELY IN KEYCHAIN!"), dismissButton: .default(Text("OK"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
//          } // form
        }.onAppear(perform: initForm)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    
    func formNotYetFilled() -> Bool {
      //self.account.ergoApiUrl
      //self.account.authKeyPwd
      //self.account.authkey
      let retval = (self.accountName.count > 2 &&
              self.authKeyString.count > 4 &&
              //self.authKeyPasswordString.count > 3 &&
              self.ergoNodeUrlString.count > 15)
      return !retval
      //!self.account.accountSettingsChanged && !self.isAccountNameChanged
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
        if (self.account_E.name == .none) {
            return
        }
        do {
           // self.accountName = self.account_E.name ?? ""
            self.authKeyString = try (secureStoreWithGenericPwd.getValue(for: "authkey") ?? "")
//            self.account.authKeyOrig = self.authkeyString
            self.authKeyPasswordString = try (secureStoreWithGenericPwd.getValue(for: "authKeyPwd") ?? "")
//            self.account.authKeyPwdOrig = self.account.authKeyPwd
            self.ergoNodeUrlString = try (secureStoreWithGenericPwd.getValue(for: "ergoApiUrl") ?? "")
//            self.account.ergoApiUrlOrig = self.account.ergoApiUrl
            self.account.isLoaded = true
            self.account.accountSettingsChanged = false
            self.accountName = self.account_E.name ?? ""
//            showSendTo = (authkey.count>0 && authKeyPwd.count>0 && ergoApiUrl.count>0)
        } catch (let e) {
          print("EXCEPTION: Loading authkey and authKeyPwd failed with \(e.localizedDescription).")
        }
    }

    
    func initForm() {
        guard let accountstr = self.account_E.id else { return }
        let assocdomain = CloudKitAndKeyChainData.securityDomain + accountstr.uuidString
        let genericPwdQueryable = GenericPasswordQueryable(service: assocdomain)
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        self.loadAuthData()
     }

    
    func saveAuthData() {
        do {
            if (!self.account.isLoaded) {
               // self.account_E.name = $accountName.wrappedValue
                guard let accountstr = self.account_E.id else { return }
                let assocdomain = CloudKitAndKeyChainData.securityDomain + accountstr.uuidString
                let genericPwdQueryable = GenericPasswordQueryable(service: assocdomain)
                secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
            }
            try secureStoreWithGenericPwd.setValue(self.authKeyString, for: "authkey")
            try secureStoreWithGenericPwd.setValue(self.authKeyPasswordString, for: "authKeyPwd")
            try secureStoreWithGenericPwd.setValue(self.ergoNodeUrlString, for: "ergoApiUrl")
            self.showingSaveSucessAlert.toggle()
            if (self.accountName != self.account_E.name) {
                  self.account_E.name = self.accountName
                  try moc.save()
            }
            self.account.authkey = self.authKeyString
            self.account.authKeyPwd = self.authKeyPasswordString
            self.account.ergoApiUrl = self.ergoNodeUrlString
            self.settings.isAuthenticated = true
            //if (0 == self.settings.selectedAccountIndex) {
                self.settings.selectedAccountIndex = self.accounts.count - 1
            //}
      } catch (let e) {
        print("EXCEPTION: Saving authkey and authKeyPwd failed with \(e.localizedDescription).")
      }
    }

}



struct Account_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(account_E: Account_E(), account: Account())
    }
}
