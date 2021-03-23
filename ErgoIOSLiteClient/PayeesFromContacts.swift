//
//  PayeesFromContacts.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 3/14/21.
//  Copyright © 2021 Bart Jenkins. All rights reserved.
//

import UIKit
import SwiftUI

struct PayeesFromContacts: View {
    @EnvironmentObject var settings: UserSettings
    @Binding var showingContactPayees: Bool
    
    var body: some View {
        Text("ERGO PAYEES:")
        let knt = self.settings.paymentsPayees.count
        if (knt > 0) {
            ForEach(0..<knt, id: \.self) { ndx in
                VStack {
                    Button("\(self.settings.paymentsPayees[ndx].payeeName)", action: {
                        self.settings.currentPayee = self.settings.paymentsPayees[ndx].payeeP2PK
                        self.showingContactPayees = false
                    })
                    Divider()
                }.font(Font.largeTitle)
            }
        } else {
            Text("None of your contacts have an 'ergo' named field.  You need to add a custom label named 'ergo' and enter p2pk addresses in them for your contacts.")
        }
    }
}



