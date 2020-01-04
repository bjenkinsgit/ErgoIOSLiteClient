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
    
    var body: some View {
        NavigationView {
            if ergTranzRealized {
                VStack {
                    Text("Tranz id:")
                    Text(ergoTransactionId)
                    Section {
                        List(self.ergoTransaction.inputs, id: \.boxId) { di in
                            Text("INPUT BOX ID:")
                            Text(di.boxId)
                        }
                    }
                }
            } else {
               Text("Getting tranz detail")
            }
        }.onAppear(perform: loadTranzDetail)
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
