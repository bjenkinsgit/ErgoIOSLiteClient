//
//  OtherAccountsPicker.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 2/28/21.
//  Copyright © 2021 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct OtherAccountsPicker: View {
    @State private var transferToAccountPickerIndex = 0
    @State var otherAccounts:[Account_E]
    @EnvironmentObject var settings: UserSettings
    @State private var showPicker = false
    @State var send2Address = ""
    @FetchRequest(entity: Account_E.entity(), sortDescriptors: []) var accounts : FetchedResults<Account_E>
    
    var body: some View {
        let selectedAccountIndexBinding = Binding<Int>(get: {
            self.transferToAccountPickerIndex
        }, set: {
            self.transferToAccountPickerIndex = $0
            
        })

        VStack {
            Picker(selection: selectedAccountIndexBinding, label:Text("")) {
                    ForEach(0..<self.otherAccounts.count, id: \.self) {
                        //if ($0 != self.settings.selectedAccountIndex) {
                          Text("\(self.otherAccounts[$0].name ?? "")")
                        //}
                    }
            }.onReceive([selectedAccountIndexBinding].publisher.first(), perform: { value in
                let account_e = self.accounts[self.transferToAccountPickerIndex]
                if let accountName = account_e.name, let addresses = account_e.addresses {
                    if (self.transferToAccountPickerIndex != self.settings.selectedAccountIndex) {
                       print(" Picker chose->\(accountName), addresses->\(addresses)")
                        send2Address = addresses
                        self.showPicker = false
                    }
                } else if let accountName = account_e.name {
                    print(" Picker chose->\(accountName), addresses->NIL")
                }
                
                
            })
            
        }
        
        
    }
    
    func initForm() {
         let accountName = self.accounts[self.settings.selectedAccountIndex].name
         self.otherAccounts = accounts.filter( {$0.value(forKey: "name") as! String != accountName! })
     }

}

struct OtherAccountsPicker_Previews: PreviewProvider {
    static var previews: some View {
        OtherAccountsPicker(otherAccounts: [Account_E]())
    }
}
