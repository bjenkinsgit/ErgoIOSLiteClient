//
//  TransactionSend.swift
//  BioMetric1
//
//  Created by Bart Jenkins on 12/26/19.
//  Copyright © 2019 Bart Jenkins. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import Contacts

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct PaymentSend: View {
    @ObservedObject var event: Payment_E
    @State var secureStoreWithGenericPwd: SecureStore!
     @ObservedObject var manager = HttpAuth()
     @EnvironmentObject var settings: UserSettings
//     @State private var send2Address = ""
     @State private var send2Amt = ""
     @State private var isShowingNanos = true
     @State private var memo = ""
     @State private var showBarCodeScanner = false
     @State private var isOkToMakePmt = false
     @State private var transferToAccountAddress = ""
     @State private var transferToAccountPickerIndex = 0
     @State private var showPicker = false
     @State private var showingContactPayees = false
     @State var otherAccounts:[Account_E]
     @ObservedObject private var keyboard = KeyboardResponder()
     @FetchRequest(entity: Account_E.entity(), sortDescriptors: []) var accounts : FetchedResults<Account_E>
     let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactRelationsKey] as [CNKeyDescriptor]
     let store = CNContactStore()
//     var payeeDict: [(String, String)]=[]
    


      var body: some View {
        let selectedAccountIndexBinding = Binding<Int>(get: {
            self.transferToAccountPickerIndex
        }, set: {
            self.transferToAccountPickerIndex = $0
            
        })
        
        let memoBinding = Binding<String>(get: {
            self.memo
        }, set: {
            self.memo = $0
            self.checkIsOkToMakePmt()
        })

         let send2AddressBinding = Binding<String>(get: {
            self.settings.currentPayee
         }, set: {
            self.settings.currentPayee = $0
            self.checkIsOkToMakePmt()
         })

         let send2AmtBinding = Binding<String>(get: {
             self.send2Amt
         }, set: {
             self.send2Amt = $0
            self.checkIsOkToMakePmt()
         })
        return NavigationView {
            VStack {
              VStack {
                Text("Payment creation date:")
                if (event.timestamp != nil) {
                   Text("\(event.timestamp!, formatter: dateFormatter)")
                }
              }
                
                VStack {
                     VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                        }
                       
                        if (self.event.tranzId == nil) {
                            Text("Memo:")
                         TextField("e.g. Pmt for services", text: memoBinding)
                             .background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                        } else {
                            HStack {
                            Text("Memo:       ")
                            Text(self.memo).foregroundColor(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                            }
                        }
                     }.padding(.bottom, 10)
                    HStack {
                        if (showBarCodeScanner) {
                            CarBode2(supportBarcode: [.qr]) //Set type of barcode you want to scan
                            .interval(delay: 5.0) //event will trigger every 5 seconds
                               .found {
                                self.settings.currentPayee = $0
                                self.checkIsOkToMakePmt()
                                self.showBarCodeScanner.toggle()
                              }
                        } else {
                            VStack(alignment: .leading) {
                                if (self.showPicker) {
                                    Picker(selection: selectedAccountIndexBinding, label:Text("")) {
                                            ForEach(0..<self.otherAccounts.count, id: \.self) {
                                                //if ($0 != self.settings.selectedAccountIndex) {
                                                  Text("\(self.otherAccounts[$0].name ?? "")")
                                                //}
                                            }
                                    }.onTapGesture {
                                        setPayeeAddressToPickedAccount()
                                    }.onReceive([selectedAccountIndexBinding].publisher.first(), perform: { value in
                                        setPayeeAddressToPickedAccount()
                                    })
                                    .onAppear(perform: {
                                        if let firstAccount = self.otherAccounts.first {
                                           if (self.settings.currentPayee.isEmpty) {
                                            self.settings.currentPayee = firstAccount.addresses ?? ""
                                           }
                                        }
                                    })
                                }
                                Text("Payee Wallet Address:")
                                if (self.event.tranzId == nil) {
                                        TextField("Pay to Address", text: send2AddressBinding).background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/).font(.subheadline).lineLimit(2)
                                    HStack {
                                        Button(action: {
                                            UIApplication.shared.endEditing()
                                            self.showBarCodeScanner = true
                                        }) {
                                            Image(systemName: "qrcode").font(Font.system(.largeTitle))
                                            .foregroundColor(.secondary).frame(maxWidth: .infinity)
                                                
                                        }
                                        Button(action: {
                                            UIApplication.shared.endEditing()
                                            self.showPicker.toggle()
                                        }) {
                                            Image(systemName: "arrowshape.zigzag.forward").font(Font.system(.largeTitle))
                                            .foregroundColor(.secondary).frame(maxWidth: .infinity)
                                            
                                        }
                                        Button(action: {
                                            UIApplication.shared.endEditing()
                                            self.showingContactPayees.toggle()
                                            
                                        }) {
                                            Image(systemName: "person.crop.circle").font(Font.system(.largeTitle))
                                            .foregroundColor(.secondary).frame(maxWidth: .infinity)
                                                
                                        }.sheet(isPresented: $showingContactPayees) {
                                            PayeesFromContacts(showingContactPayees: $showingContactPayees)
                                        }
                                    }
                                } else {
                                    Text(self.settings.currentPayee).foregroundColor(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/).multilineTextAlignment(.leading)
                                }
                            }.padding(.bottom, 10)
                        } 
                     }
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                    }
                    if (self.event.tranzId == nil) {
                      Text("Pay amount (in nano ERGs):")
                      TextField("eg. 10000000000", text: send2AmtBinding)
                        .keyboardType(.numberPad)
                        
                        .background(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/)
                    } else {
                        HStack {
                            Text("Paid amount:")
                                Text("\(getSentAmtFormatted())").foregroundColor(/*@START_MENU_TOKEN@*/Color.orange/*@END_MENU_TOKEN@*/).onTapGesture{ self.isShowingNanos.toggle() }
                        }
                    }
                }
            }
                
                     NavigationLink(destination: TransactionDetails(payeeAddress: self.event.sendToAddress ?? "",
                                                                    ergoTransactionId:self.event.tranzId ?? "",
                                                                    manager: self.manager
                                                                    ))
                     {
                         VStack {
                           Text("Transaction id:")
                           Text("\((self.event.tranzId ?? ""))")
                         }
                    }.disabled(notProperTranzId()) // NavigationLink
            } // VStack
            .frame(minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity)
            .adaptsToKeyboard()
        } // NavigationView
        .navigationBarTitle("Send Payment Form", displayMode: .inline)
            .alert(isPresented: $manager.showingPaymentErrorAlert) {
                Alert(title: Text("Payment Send Error"), message: Text(manager.error_detail), dismissButton: .default(
                 Text("OK"),action: alertCleared
                 ))
        }
        .onAppear(perform: initForm)
         .navigationViewStyle(StackNavigationViewStyle())
        .animation(.easeOut(duration: 0.16))
        .navigationBarItems(trailing:
         HStack {
               Button(action: sendPayment) {
                 Text("Send Payment")
               }.disabled(!self.isOkToMakePmt)
         })
 

      }
    
    func setPayeeAddressToPickedAccount() {
        let account_e = self.otherAccounts[self.transferToAccountPickerIndex]
        if let accountName = account_e.name, let addresses = account_e.addresses {
            if (self.settings.currentPayee != addresses) {
               print(" Picker chose->\(accountName), addresses->\(addresses)")
                self.settings.currentPayee = addresses
               
            }
        }
}
    func pickAPayeeFromContacts() {
        let request = CNContactFetchRequest(keysToFetch: keysToFetch )
        var contacts = [CNContact]()
        self.settings.paymentsPayees.removeAll()
//        var localPayeeDict: [(String, String)]=[]
        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                contacts.append(contact)
                let fname = contact.givenName
                let lname = contact.familyName
                    for (relation) in contact.contactRelations {
                        if (relation.label=="ergo") {
                            let p2pkval = relation.value
                            let x = p2pkval.name
                            print(fname, lname, x)
                            let payee = self.settings.createPaymentsPayee(name: "\(fname) \(lname)", p2pk: "\(x)")
                            self.settings.paymentsPayees.append(payee)
                            //localPayeeDict.append(contentsOf: [("\(fname) \(lname)","\(x)")])
                        } // if
                    } // for
            }
        } catch {
            print("Failed to fetch contact, error: \(error)")
            // Handle the error
        }
    }
    
    
    func getSentAmtFormatted() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let send2AmtVal = Double(self.send2Amt.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
            var wholeErgs: Double = 0.0
            var units = "nERG"
            if (self.isShowingNanos) {
                wholeErgs = send2AmtVal
            } else {
                wholeErgs = send2AmtVal / Double(1000000000.0)
                units = "ERG"
            }
            let retval = numberFormatter.string(from: NSNumber(value: wholeErgs)) ?? ""
            return retval + " " + units
        } else {
            return self.send2Amt + " err"
        }
    }
    
    func notProperTranzId()->Bool {
        guard let tid = self.event.tranzId  else { return true }
        return (tid == "no_tranz_id_yet" || tid.count == 0)
    }
    
    func alertCleared() {
        self.manager.showingPaymentErrorAlert = false
//        self.event.tranzId = "no_tranz_id_yet"
//        self.event.sendToAddress = self.send2Address
//        self.event.memo = self.memo
//        self.event.sendToAmount = Double(self.send2Amt) ?? 0.0
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func checkIsOkToMakePmt() {
//        let localtid = manager.tranzId
//        print("tranzId = \(localtid)")
        isOkToMakePmt = self.send2Amt.count > 0 && manager.tranzId.count==0 && self.memo.count > 3 && self.settings.currentPayee.count > 15
    }
    
    func initForm() {
        print(event.tranzId ?? "NO Tranz id")
        self.settings.currentPayee = event.sendToAddress ?? ""
         manager.tranzId = event.tranzId ?? ""
         let string = event.sendToAmount==0 ? "" : String(format: "%12.0f", event.sendToAmount)
         self.send2Amt = string
         self.memo = event.memo ?? ""
        let accountName = self.accounts[self.settings.selectedAccountIndex].name
        self.otherAccounts = self.accounts.filter( {$0.value(forKey: "name") as! String != accountName! })
         pickAPayeeFromContacts()
     }

       func sendPayment() {
            let amt: Int64? = Int64(self.send2Amt)
            if (amt != nil && self.settings.currentPayee.count > 0) {
                self.manager.sendPaymentRequest(self.settings.account.ergoApiUrl, self.settings.account.authkey, self.settings.currentPayee, amt!,
                                                self.settings.account.authKeyPwd,completionHandler: { (transid: String)  in
                    DispatchQueue.main.async {
                        self.event.tranzId = transid
                        self.event.sendToAddress = self.settings.currentPayee
                        self.event.memo = self.memo
                        self.event.sendToAmount = Double(self.send2Amt) ?? 0.0
                        self.isOkToMakePmt = false
                        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                    }
                })
            } else {
                print("Found Nil for 'amt' to send.")
            }
        }
    

    struct PaymentSend_Previews: PreviewProvider {
        static var previews: some View {
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           //Test data
                   let newPayment_E = Payment_E.init(context: context)
//            let paymentsPayee = PaymentsPayee.init()
            newPayment_E.memo = "memo goes here"
            newPayment_E.sendToAddress = "3WynPS3DCQ8pD21vd6QGdSSThyUVn1fXoDVxn2AGEwFNshvz4Jzi"
//            newPayment_E.sendToAddress = "Now is the time for all good men to come to the aid of their party"
            newPayment_E.sendToAmount = 1250000000
            
                   newPayment_E.timestamp = Date()
            return PaymentSend(event: newPayment_E, otherAccounts: [Account_E]()).environment(\.managedObjectContext, context)
        }
    }
}
