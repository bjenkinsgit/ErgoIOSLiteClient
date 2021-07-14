//
//  ContentView.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/1/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import Security
import Network
import CoreImage.CIFilterBuiltins


struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var settings: UserSettings
    
    @State private var timerInterval: Double = 10.0  // secs
    @State var secureStoreWithGenericPwd: SecureStore!
    @State private var isUnlocked = false
    @State private var initialLaunch = true
    @ObservedObject var manager = HttpAuth()
    @State private var monitor  = NWPathMonitor()
    @State private var isAccountSettingsFilledIn = false
    @State private var isShowingNanos = true
    @State private var isInClearScreenMode = false
    @State private var syncd = false
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    //@ObservedObject var account_E: Account_E
    @FetchRequest(entity: Account_E.entity(), sortDescriptors: []) var accounts : FetchedResults<Account_E>
//    @State private var selectedAccountIndex = 0
    @State private var oldSelectedAccountIndex = 0
    
    //let heartBeat = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State var heartBeat: Timer.TimerPublisher = Timer.publish (every: 10, on: .main, in: .common)

    
        var body: some View {
            let selectedAccountIndexBinding = Binding<Int>(get: {
                self.settings.selectedAccountIndex
            }, set: {
                self.settings.selectedAccountIndex = $0
                if let accountUUIDStr = self.accounts[self.settings.selectedAccountIndex].name {
                    self.setSecureAssocDomain(accountUUID: accountUUIDStr)
                }
            })

            return VStack {
                if (manager.isOnline && self.accounts.count > 0) {
                    if (self.syncd && manager.isWalletInitialized && self.manager.walletBalance >= 0) {
                        if (self.settings.isAuthenticated) {
                            if (self.isShowingNanos) {
                                Text("Balance: \(manager.walletBalance) nERG")
                                    .onTapGesture{ self.isShowingNanos.toggle() }
                            } else {
                                Text("Balance: \(Double(manager.walletBalance) / 1000000000.0) ERG")
                                .onTapGesture{ self.isShowingNanos.toggle() }
                            }
                        } else {
                            Text("")
                        }
                    } else {
                        if (self.manager.isWalletInitialized && self.manager.isWalletUnlocked
                            && self.accounts.count > 0
                            ) {
                            Text("Synchronizing with blockchain").animation(.easeIn)
                        } else {
                            if (!manager.isWalletInitialized && self.accounts.count > 0) {
                                Text("Wallet is NOT initialized...")
                            } else {
                                if (self.accounts.count == 0) {
                                    Text("Please create an account!")
                                } else {
                                    Text("<NO Accounts>")
                                }
                            }
                        }
                    }
                } else {
                    if (self.isInClearScreenMode) {
                        Text("")
                    } else
                        if (self.accounts.count == 0) {
                           Text("Please add an account")
                        } else {
                           Text("<ERGO node offline>")
                        }
                }
        
            NavigationView {
               VStack(spacing: 20) {
                if (!self.isInClearScreenMode && self.settings.fullHeightVal == self.settings.headersHeightVal && self.settings.fullHeightVal > 0 && self.accounts.count > 0 && self.settings.isAuthenticated) {
                    Image(uiImage: generateQRCode()).interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .contextMenu {
                            Button(action: {
                                let pasteboard = UIPasteboard.general
                                pasteboard.image = generateQRCode()
                            }) {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                    Text("\(self.manager.walletAddresses.first ?? "")")
                        .contextMenu {
                            Button(action: {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = self.manager.walletAddresses.first ?? ""
                            }) {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                }
                if (self.accounts.count > 0) {
                    VStack {
                        SyncStatusView()
                    }
                    VStack {                      
                        Picker(selection: selectedAccountIndexBinding, label:Text("")) {
                                ForEach(0..<self.accounts.count, id: \.self) {
                                    Text("\(self.accounts[$0].name ?? "")")
                                }.onDelete(perform: deleteAccount)
//                                .onChange(of: self.accounts.count, perform: { value in
//                                    self.loadAuthData()
//                                })
                        }.labelsHidden()
                        .id("selai \(self.settings.selectedAccountIndex)")
                               .onTapGesture {
                                //print("PICKER TAPPED!")
                            }.onAppear(perform: doOnAppear)
                             .onDisappear{
                                //print("PICKER DIS-appeared")
                                self.cancelTimer()
                                self.isAccountSettingsFilledIn = self.accounts.count > 0
                                self.oldSelectedAccountIndex = self.settings.selectedAccountIndex
                            }
                            .onReceive([self.settings.selectedAccountIndex].publisher.first()) { (value) in          self.settings.defaults.set(self.settings.selectedAccountIndex, forKey: "DefaultAccount")
                                if (self.oldSelectedAccountIndex != self.settings.selectedAccountIndex) {
                                    //print(self.accounts[value].name ?? "No_account_name")
                                    manager.ignoreCommsError = true // if a http request is already in flight to a non-functioning site, ignore the time-out error.
                                    self.setAccount()  // this will load data as well
                                }
                            }
                    } // Vstack
                } else {
                    Text("Tap the 'Account' link to add at least one account.")
                }
                NavigationLink(destination: Accounts()) {
                     Text("Accounts")
                }

                NavigationLink(destination: NodeInfoView(urlstr: self.settings.account.ergoApiUrl)) {
                         Text("Node Info")
                }.disabled(self.isInClearScreenMode &&  !isAccountSettingsFilledIn && !self.manager.isOnline)
                    Button(action: updateWalletBalance) {
                        Text("Get Latest Balance")
                    }.disabled(isDisabled())
                     .onReceive(heartBeat) { input in
                        print("**** HEARTBEAT received....")
                        if (self.accounts.count > 0) {
                            self.updateNodeInfoVals()
                            
                            if (self.syncd) {
                               self.updateWalletBalance()
                            }
                        }
                      } // .onReceive
                NavigationLink(destination: Payments()) {
                  Text("Payments")
                }.disabled(isDisabled())
                
            }.navigationBarTitle("ERGO API Client Main", displayMode: .inline)
            .alert(isPresented: $manager.showingPaymentErrorAlert) {
                    Alert(title: Text("Communication Error"), message: Text(manager.error_detail), dismissButton: .default(
                     Text("OK"),action: alertCleared
                     ))
            }
            
           }.onAppear {
              self.initForm()
              self.setAccount()
            }
            
            .navigationViewStyle(StackNavigationViewStyle())
            
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.authenticate()
            }
    }
    
    func generateQRCode() -> UIImage {
        if let string = self.manager.walletAddresses.first {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
        } else {
            return UIImage()
        }
    }

    
    
    func updateNodeInfoVals() {
        self.manager.getInfo(self.settings.account.ergoApiUrl, completionHandler: { (result: NodeInfo)  in
            if (!self.manager.isWalletInitialized) {
                self.updateWalletBalance()
            }
            //print("Wallet is initialized? \(self.manager.isWalletInitialized)")
            //self.syncd = false
            self.isInClearScreenMode = false
            self.settings.progressBarValue = 0
            let fHeight = result.fullHeight ?? 0
            let hHeight = result.headersHeight ?? 0
            self.settings.fullHeightVal = fHeight
            self.settings.headersHeightVal = hHeight
            if (self.settings.headersHeightVal > 0) {
                self.settings.progressBarValue = CGFloat(Double(self.settings.fullHeightVal) / Double(self.settings.headersHeightVal))
            }
            self.syncd = result.fullHeight == result.headersHeight
            if (self.syncd) {
                self.cancelTimer()
            }
        })
    }
            
    func instantiateTimer() {
       self.heartBeat = Timer.publish (every: 10, on: .main, in: .common)
    }
    
    func cancelTimer() {
        self.heartBeat.connect().cancel()
    }
    
    func deleteAccount(at offsets: IndexSet) {
        for offset in offsets {
            let account = self.accounts[offset]
            viewContext.delete(account)
        }
        try? viewContext.save()
    }
    
    func doOnAppear() {
        let numAccts = self.accounts.count
        if (0 == self.settings.selectedAccountIndex &&  numAccts > 0) {
            self.settings.selectedAccountIndex = self.accounts.count
        }
        self.instantiateTimer() // You could also consider an optional self.timer variable.
//        self.heartBeat.connect() // This allows you to manually connect where you want with greater efficiency, if you don't always want to autostart.
        if (!self.manager.isOnline) {
            self.setAccount()
        }
        if (self.isAccountSettingsFilledIn) {
            //print(" # accounts=\(self.accounts.count)")
            //print(" selAcctIndex=\(self.settings.selectedAccountIndex)")
            if (self.accounts.count == 0) {
                self.syncd = false
                self.manager.isWalletInitialized = false
                self.initForm()
            } else {
                //for account in self.accounts {
                //    print(" ACCOUNT ")
                //    print(account.id ?? "Account id not found")
                //    print(account.name ?? "Account name not found")
               //}
                if (self.settings.lastKnownNumberOfAccounts != self.accounts.count) {
                    self.setAccount()
                } else
                    if (self.settings.selectedAccountIndex > (self.accounts.count - 1)) {
                       self.settings.selectedAccountIndex = self.accounts.count - 1
                    }
                //self.updateNodeInfoVals()
            }
        } else {
            print("** doOnAppear inert beause not yet authenticated...")
        }
        
    }
    
    func alertCleared() {
        manager.showingPaymentErrorAlert = false
        self.isAccountSettingsFilledIn = false
        self.syncd = false
    }
    func isDisabled() -> Bool {
        return !(!self.isInClearScreenMode && self.isAccountSettingsFilledIn && self.syncd)
    }
    
    func checkAndSetAddress() {
        self.manager.getWalletAddresses(self.settings.account.ergoApiUrl, self.settings.account.authkey,
                                        completionHandler: { (result: [String])  in
            //print("&&&& Wallet Addresses &&&&&")
            if (result.count > 0) {
                self.manager.walletAddresses = result
                let account_E = self.accounts[self.settings.selectedAccountIndex]
                let joinedListOfAddress = result.joined(separator:"|")
                if (joinedListOfAddress != account_E.addresses) {
                    print("** ADDRESSES has changed from \(account_E.addresses ?? "<no addresses yet>") to \(joinedListOfAddress)")
                    account_E.addresses = joinedListOfAddress
                    
                    do {
                        try viewContext.save()
                    } catch (let e) {
                        print("!!!!!!! Error trying to save address listing to database ->\(e.localizedDescription)")
                    }
                }
              //  print(self.manager.walletAddresses)
            }
        })
    }
    
        func updateWalletBalance() {
            print("******** update wallet balance called ********")
            let url = self.settings.account.ergoApiUrl
            let authkey = self.settings.account.authkey
            let authkeypwd = self.settings.account.authKeyPwd
            self.manager.getWalletStatus(url, authkey, completionHandler: { (isTheWalletUnlocked: Bool)  in
                    if (!isTheWalletUnlocked) {
                        self.manager.unlockWalletPost(url, authkey,authkeypwd,
                             completionHandler: { (statusString: String)  in
                                //self.manager.getWalletStatus(self.settings.account.ergoApiUrl, self.settings.account.authkey)
                                self.manager.getBal(self.settings.account.ergoApiUrl, self.settings.account.authkey)
                                checkAndSetAddress()
                             }
                        )
                    }
                     else {
                        self.syncd = true
                        self.manager.getBal(self.settings.account.ergoApiUrl, self.settings.account.authkey)
                        checkAndSetAddress()
                    }
            })
    }

    func setSecureAssocDomain(accountUUID: String) {
        let assocdomain = CloudKitAndKeyChainData.securityDomain + accountUUID
        let genericPwdQueryable = GenericPasswordQueryable(service: assocdomain)
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        //print("-----> setSecureAssocDomain is calling loadAuthData")
        //self.loadAuthData()
    }

    func clearScreen() {
        manager.isOnline = false
        self.isInClearScreenMode = true
    }
        func loadAuthData() {
            self.clearScreen()
            do {
//                self.accountName = try (secureStoreWithGenericPwd.getValue(for: "accountName") ?? "")
                let authkey = try (secureStoreWithGenericPwd.getValue(for: "authkey") ?? "")
                let authKeyPwd = try (secureStoreWithGenericPwd.getValue(for: "authKeyPwd") ?? "")
                let ergoApiUrl = try (secureStoreWithGenericPwd.getValue(for: "ergoApiUrl") ?? "")
                self.settings.account.authkey = authkey
                self.settings.account.authKeyPwd = authKeyPwd
                self.settings.account.ergoApiUrl = ergoApiUrl
//                if (self.settings.account.authkey.count > 0 && self.settings.account.authKeyPwd.count > 0 &&
                if (self.settings.account.ergoApiUrl.count > 0) {
                    self.isAccountSettingsFilledIn = true
                    self.manager.getInfo(self.settings.account.ergoApiUrl, completionHandler: { (result: NodeInfo)  in
                        //guard let fHeight = result.fullHeight, let hHeight = result.headersHeight else {
                            //return
                        self.syncd = true
                        
                       self.updateWalletBalance()
                       // self.settings.account.isLoaded = true
                        self.updateNodeInfoVals()
                       // }
                    })
                    
                } else {
                    manager.showingPaymentErrorAlert = true
                }
                
            } catch (let e) {
              print("EXCEPTION: Loading authkey and authKeyPwd failed with \(e.localizedDescription).")
            }
        }
        
        func authenticate() {
            #if targetEnvironment(simulator)
              self.loadAuthData()
              self.settings.isAuthenticated = true
            #else
             let context = LAContext()
             var error: NSError?
            //print("***** AUTHENTICATING *******")
             // check whether biometric authentication is possible
             if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                 // it's possible, so go ahead and use it
                 let reason = "We need to unlock your data."

                 context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                     // authentication has now completed
                     DispatchQueue.main.async {
                         if success {
                            print("-----> authenticate is calling loadAuthData")
                            self.loadAuthData()
                            self.settings.isAuthenticated = true
                         } else {
                             _ = Alert(title: Text("Important message"), message: Text("Authentication unsuccessful"), dismissButton: .default(Text("OK")))
                         }
                     }
                 }
             } else {
                 _ = Alert(title: Text("Important message"), message: Text("Biometric Authentication not available"), dismissButton: .default(Text("OK")))
             }
            #endif
         }

    func setAccount() {
        if (self.settings.selectedAccountIndex < 0) { self.settings.selectedAccountIndex = 0 }
//        var isAuthenticated: Bool = self.settings.isAuthenticated
//        var oldIndex = self.oldSelectedAccountIndex
//        var selIndex = self.settings.selectedAccountIndex
        if (!self.settings.isAuthenticated || self.oldSelectedAccountIndex != self.settings.selectedAccountIndex) {
//            let numaccounts = self.accounts.count
//            let savedAcctIndex = self.settings.selectedAccountIndex
            if (self.accounts.count > 0) {
                if self.settings.selectedAccountIndex >= self.accounts.count {
                    self.settings.selectedAccountIndex = 0
                }
                if (self.settings.lastKnownNumberOfAccounts != self.accounts.count) {
                    self.settings.lastKnownNumberOfAccounts = self.accounts.count
                    self.settings.selectedAccountIndex = self.accounts.count - 1
                }
                self.isAccountSettingsFilledIn = self.accounts.count > 0
                if let accountstr = self.accounts[self.settings.selectedAccountIndex].id {
                    let assocdomain = CloudKitAndKeyChainData.securityDomain + accountstr.uuidString
                    let genericPwdQueryable = GenericPasswordQueryable(service: assocdomain)
                    if (self.oldSelectedAccountIndex != self.settings.selectedAccountIndex) {
                        self.oldSelectedAccountIndex = self.settings.selectedAccountIndex
                    }
                    self.secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
                    if (false == self.settings.isAuthenticated) {
                      self.authenticate()
                    } else {
                        print("-----> setAccountData is calling loadAuthData")
                        self.loadAuthData()
                    }
                }
            }
        }
    }
    
    func startNetworkStatusMonitoring() {
//        var accountsKnt = self.accounts.count
        if (0 == self.accounts.count) {
            return
        }
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
            if path.status == .satisfied {
                if (!self.manager.isOnline || self.manager.showingPaymentErrorAlert) {
                  self.manager.showingPaymentErrorAlert = false
                  print("-----> startNetworkStatusMonitoring is calling loadAuthData")
                  self.loadAuthData()
                  self.updateWalletBalance()
                }
            } else {
                  self.manager.showingPaymentErrorAlert = true
                  self.manager.error_detail = "You are offline.  No Connection."
                  self.manager.isOnline = false
            }
           // print(path.isExpensive)
        }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        if (!self.settings.networkMonitoringStarted) {
          self.settings.networkMonitoringStarted = true
        }
    }

    func initForm() {
        if (false == self.settings.networkMonitoringStarted) {
            startNetworkStatusMonitoring()
        }
//        var isAuthenticated: Bool = self.settings.isAuthenticated
//        var oldIndex = self.oldSelectedAccountIndex
//        var selIndex = self.settings.selectedAccountIndex
//        var accountsKnt = self.accounts.count
        if (!self.settings.isAuthenticated || self.oldSelectedAccountIndex != self.settings.selectedAccountIndex) {
            if (self.manager.showingPaymentErrorAlert) {
               self.manager.showingPaymentErrorAlert = false
            }
            self.setAccount()
        }
        
    }

    }



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
