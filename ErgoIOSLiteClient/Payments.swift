//
//  Payments.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/1/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct Payments: View {
    @Environment(\.managedObjectContext)
    var viewContext
    
    var body: some View {
        NavigationView {
            MasterView()
                .navigationBarTitle("Payments",displayMode: .inline)
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            withAnimation { Payment_E.create(in: self.viewContext) }
                        }
                    ) {
                        Text("Create a payment")
                    }
                )
       }.navigationViewStyle(StackNavigationViewStyle())  
    }
}

struct MasterView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Payment_E.timestamp, ascending: true)],
        animation: .default)
    var events: FetchedResults<Payment_E>

    @Environment(\.managedObjectContext)
    var viewContext

    var body: some View {
        List {
            ForEach(events, id: \.self) { event in
                NavigationLink(
//                    destination: DetailView(event: event)
                    destination: PaymentSend(event: event)
                ) {
                    VStack {
                      Text("\(event.timestamp!, formatter: dateFormatter)").font(.headline)
                      Text("Memo: \(event.memo ?? "")")
                    }
                }
            }.onDelete { indices in
                self.events.delete(at: indices, from: self.viewContext)
            }  
        }
    }
}

struct Payments_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return Payments().environment(\.managedObjectContext, context)
    }
}
