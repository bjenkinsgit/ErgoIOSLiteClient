//
//  Payments.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/1/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI
import CoreData

struct Payments: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        NavigationView {
            MasterView(halfAuthKey: settings.account.halfAuthKey)
                .navigationBarTitle("Payments",displayMode: .inline)
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            withAnimation {
                                print("--> PLUS symbol touched.")
                                Payment_E.create(in: self.viewContext, self.settings.account.halfAuthKey)
                                
                            }
                        }
                    ) {
                        Image(systemName: "plus")
                    }
                )
        }.onAppear {
            initForm(self.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

func initForm(_ viewContext: NSManagedObjectContext) {
    viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
}

struct MasterView: View {
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Payment_E.timestamp, ascending: true)],
//        animation: .default)
//    var events: FetchedResults<Payment_E>

    var fetchRequest: FetchRequest<Payment_E>
    var events: FetchedResults<Payment_E> { fetchRequest.wrappedValue }

    @Environment(\.managedObjectContext) var viewContext
    
    init(halfAuthKey: String) {
        fetchRequest = FetchRequest<Payment_E> (entity:
            Payment_E.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Payment_E.timestamp, ascending: true)],
            predicate: NSPredicate(format: "halfAuthKey == %@", halfAuthKey),
            animation: .default
        )
    }
    
    var body: some View {
        List {
            ForEach(self.events, id: \.self) { event in
                NavigationLink(
                    destination: PaymentSend(event: event)
                ) {
                    VStack {
                      Text("\(event.timestamp!, formatter: dateFormatter)").font(.headline)
                        Text("Memo: \(event.memo ?? "")").font(.subheadline)
//                        Text("Memo: \(event.tranzId ?? "")").font(.subheadline)
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
