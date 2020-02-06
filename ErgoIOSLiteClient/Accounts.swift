//
//  Accounts.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/28/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct RefreshView: View {
    @State private var toggle = false
    public init(toggle: Bool) {
        self.toggle = toggle
    }
    var body : some View {
        EmptyView()
    }
}

struct Accounts: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Account_E.entity(), sortDescriptors: []) var accounts : FetchedResults<Account_E>
    @State private var needsRefresh = false
    
    var body: some View {
      NavigationView {
        VStack {
            List {
                ForEach(accounts, id: \.id) { account_e in
                    NavigationLink(
                        destination: AccountSettingsView(account_E: account_e, account: Account())
                    )
                    {
                        Text("Account: \(account_e.name ?? "<unnamed>")")
                        RefreshView(toggle: self.needsRefresh)
                    }
                }.onDelete { ndx in
                    self.accounts.deleteAccount(at: ndx, from: self.moc)
                }
            }.navigationBarTitle(Text("Accounts"))
            .background(RefreshView(toggle: self.needsRefresh   ))
            
            Button("Add") {
                Account_E.createAccount(in: self.moc, .none)
            }
        }
        }
        
    }
    
}



struct Accounts_Previews: PreviewProvider {
    static var previews: some View {
        Accounts()
    }
}
