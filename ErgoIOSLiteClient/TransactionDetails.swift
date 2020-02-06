//
//  TransactionDetails.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/1/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct TransactionDetails: View {
    @State var payeeAddress = ""
    @State var ergoTransactionId = ""
    @State var manager = HttpAuth()
    @State private var ergTranzRealized = false
    @State private var ergoTransaction = ErgoTransaction()
    @State private var showingSheet = false
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        NavigationView {
            if ergTranzRealized {
                VStack {
                    Text("Tranz id:")
                    Text(ergoTransactionId)
                        .foregroundColor(.yellow)
                        .contextMenu {
                            Button(action: {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = self.ergoTransactionId                                
                            }) {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                        
                    
                    Section {
                        VStack {
                            Text("Confirmations: \(self.ergoTransaction.numConfirmations ?? 0)")
//                            List(self.ergoTransaction.inputs, id: \.boxId) { di in
//                                Text("INPUT BOX ID:")
//                                Text(di.boxId)
//                            }
                            List(self.ergoTransaction.outputs, id: \.value) { di in
                                if (di.address.count == 52) {
                                    if (di.address == self.payeeAddress) {
                                        Text("Payee Amount:     ")
                                    } else {
                                        Text("Coins Returned:")
                                    }
                                } else {
                                        Text("Output Tx Fee:    ")
                                }
                                Text(String(Double(di.value) / Double(1000000000)))
                            }
                        }
                    }
                }
            } else {
               Text("Not available yet...please wait a few minutes")
            }
        }.onAppear(perform: loadTranzDetail)
        .navigationViewStyle(StackNavigationViewStyle())  
    }

    func loadTranzDetail() {
        self.manager.getWalletTranzById(settings.account.ergoApiUrl, settings.account.authkey, ergoTransactionId,completionHandler: { (ergtranz: ErgoTransaction)  in
            self.ergoTransaction = ergtranz
            self.ergTranzRealized.toggle()
            })
    }
}

struct TransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetails()
    }
}
