//
//  TransactionDetails.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/1/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct TransactionDetails: View {
    @State var ergoTransactionId = ""
    @State var authKey = ""
    @State var urlstr = ""
    @State var manager = HttpAuth()
    @State private var ergTranzRealized = false
    @State private var ergoTransaction = ErgoTransaction()
    @State private var showingSheet = false
    
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
                        List(self.ergoTransaction.inputs, id: \.boxId) { di in
                            Text("INPUT BOX ID:")
                            Text(di.boxId)
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
        self.manager.getWalletTranzById(urlstr, authKey, ergoTransactionId,completionHandler: { (ergtranz: ErgoTransaction)  in
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
