//
//  SyncStatusView.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 4/12/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct SyncStatusView: View {
    @ObservedObject var manager = HttpAuth()
    @EnvironmentObject var settings: UserSettings    
    @State private var syncTimer = Timer.publish(every: 10, on: .main, in: .common)
    @State private var timerIsRunning = false
    
    var body: some View {
        VStack {
            
            if (self.settings.fullHeightVal != self.settings.headersHeightVal) {
                if (self.settings.fullHeightVal > 0) {
                   CircularProgressBar(value: $settings.progressBarValue)
                } else {
                    Text("Headers Height: \(self.settings.headersHeightVal)")
                    .animation(.easeInOut)
                    .id("Headers Height:  \(self.settings.headersHeightVal)")
                }
                
            } else {
                if (self.settings.fullHeightVal == 0 && self.settings.headersHeightVal == 0)  {
                    VStack {
                        Text("Synchronizing...")
                        Text("Headers Height: \(self.settings.headersHeightVal)")
                    }
                }
            }
        }.onAppear(perform: dumpFhHh)
    }
    
    func dumpFhHh() {
        let fh = self.settings.fullHeightVal
        let hh = self.settings.headersHeightVal
        print(fh,hh)
    }
}

struct SyncStatusView_Previews: PreviewProvider {
    static var previews: some View {
        SyncStatusView()
    }
}
