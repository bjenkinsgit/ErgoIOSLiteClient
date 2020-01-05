//
//  TransactionSend.swift
//  BioMetric1
//
//  Created by Bart Jenkins on 12/26/19.
//  Copyright © 2019 Bart Jenkins. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct PaymentSend: View {
    @ObservedObject var event: Payment_E
    @State var secureStoreWithGenericPwd: SecureStore!
    @ObservedObject var manager = HttpAuth()
    @State private var authkey = ""
    @State private var authKeyPwd = ""
    @State private var ergoApiUrl = ""
    @State private var send2Address = ""
    @State private var send2Amt = ""
    @State private var memo = ""
    @State private var showBarCodeScanner = false
    @ObservedObject private var keyboard = KeyboardResponder()

      var body: some View {
         NavigationView {
            VStack {
               Section {
                   Text("Payment creation date:")
                   Text("\(event.timestamp!, formatter: dateFormatter)").padding(.bottom, 100)
               }
               
               Section {
                   VStack(alignment: .leading) {
                     Text("Memo:")
                       TextField("e.g. Pmt for services", text: $memo)
                           .background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                           
                   }
               }
                Section {
                   HStack {
                       if (showBarCodeScanner) {
                           CarBode2(supportBarcode: [.qr]) //Set type of barcode you want to scan
                           .interval(delay: 5.0) //Payment_E will trigger every 5 seconds
                              .found {
                               self.send2Address = $0
                               self.showBarCodeScanner.toggle()
                             }
                       } else {
                           VStack(alignment: .leading) {
                               Text("Payee Wallet Address:")
                               HStack {
                                   TextField("Pay to Address", text: $send2Address).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/).font(/*@START_MENU_TOKEN@*/.caption/*@END_MENU_TOKEN@*/)
                                   Button(action: {
                                       self.showBarCodeScanner.toggle()
                                   }) {
                                       Image(systemName: "qrcode")
                                       .foregroundColor(.secondary)
                                   }
                               }
                           }
                       }
                    }
               }
               VStack(alignment: .leading) {
                   Text("Pay amount (in nano ERGs):")
                   TextField("eg. 10000000000", text: $send2Amt).keyboardType(.numberPad).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/).padding(.bottom,50)
               }
               VStack {
                   if (manager.tranzId.count > 0) {
                       NavigationLink(destination: TransactionDetails(ergoTransactionId:manager.tranzId,
                                                                      authKey: self.authkey,
                                                                      urlstr: self.ergoApiUrl,
                                                                      manager: self.manager)) {
                           VStack {
                             Text("Tranz id:")
                             Text("\(manager.tranzId)")
                           }
                       }
                   }
               }
               if (self.send2Amt.count > 0 && manager.tranzId.count==0 && self.memo.count > 0 && self.send2Address.count > 15) {
                   Button(action: sendPayment) {
                       HStack {
                           Text("Make Payment")
                               .fontWeight(.semibold)
                               .font(.title)
                       }
                       .frame(minWidth: 0, maxWidth: .infinity)
                       .padding()
                       .foregroundColor(.blue)
                   }
               }
           }.navigationBarTitle("Send Payment Form", displayMode: .inline)
               .alert(isPresented: $manager.showingPaymentErrorAlert) {
                   Alert(title: Text("Payment Send Error"), message: Text(manager.error_detail), dismissButton: .default(Text("OK")))
           }
           }.onAppear(perform: initForm)
           .padding(.bottom, keyboard.currentHeight)
           .edgesIgnoringSafeArea(.bottom)
           .animation(.easeOut(duration: 0.16))
       }
    
    func updatePayment_ECallback(tranzid: String) {
            event.tranzId = tranzid
    }
        
        func loadAuthData() {
             do {
                 authkey = try (secureStoreWithGenericPwd.getValue(for: "authkey") ?? "")
                 authKeyPwd = try (secureStoreWithGenericPwd.getValue(for: "authKeyPwd") ?? "")
                 ergoApiUrl = try (secureStoreWithGenericPwd.getValue(for: "ergoApiUrl") ?? "")
             } catch (let e) {
               print("EXCEPTION: Loading authkey and authKeyPwd failed with \(e.localizedDescription).")
             }
         }

        func initForm() {
            let genericPwdQueryable = GenericPasswordQueryable(service: "56F7835N8P.com.amc.ergo.client1")
            secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
            if (secureStoreWithGenericPwd == nil) {
                print("TransactionSend.swift - SECURE STORE INIT is NULL!")
            } else {
                self.loadAuthData()
            }
            self.send2Address = event.sendToAddress ?? ""
            manager.tranzId = event.tranzId ?? ""
            let string = event.sendToAmount==0 ? "" : String(format: "%12.0f", event.sendToAmount)
            self.send2Amt = string
            self.memo = event.memo ?? ""
            
        }

        func sendPayment() {
            // sendPaymentRequest(_ urlstr: String, _ api_key: String, _ toAddress: String, _ amt: Int64) {
        
            if (self.authkey.count == 0 || self.authKeyPwd.count == 0 || self.ergoApiUrl.count == 0) {
                self.authenticate()
            }
            let amt: Int64? = Int64(self.send2Amt)
            if (amt != nil && self.send2Address.count > 0) {
                self.manager.sendPaymentRequest(self.ergoApiUrl, self.authkey, self.send2Address, amt!, completionHandler: { (transid: String)  in
                    self.event.tranzId = transid
                    self.event.sendToAddress = self.send2Address
                    self.event.memo = self.memo
                    self.event.sendToAmount = Double(self.send2Amt) ?? 0.0
                    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                })
            } else {
                print("Found Nil for 'amt' to send.")
            }
        }
        
        
        func authenticate() {
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
                         } else {
                             _ = Alert(title: Text("Important message"), message: Text("Authentication unsuccessful"), dismissButton: .default(Text("OK")))
                         }
                     }
                 }
             } else {
                 _ = Alert(title: Text("Important message"), message: Text("Biometric Authentication not available"), dismissButton: .default(Text("OK")))
             }
         }

    }

    struct PaymentSend_Previews: PreviewProvider {
        static var previews: some View {
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           //Test data
                   let newPayment_E = Payment_E.init(context: context)
            newPayment_E.memo = "memo goes here"
            newPayment_E.sendToAddress = "3WynPS3DCQ8pD21vd6QGdSSThyUVn1fXoDVxn2AGEwFNshvz4Jzi"
            newPayment_E.sendToAmount = 1.25
            
                   newPayment_E.timestamp = Date()
            return PaymentSend(event: newPayment_E).environment(\.managedObjectContext, context)
        }

}
