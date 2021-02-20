//
//  NodeInfoView.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 1/24/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct NodeInfoView: View {
    @State private var manager = HttpAuth()
    @State var currNodeInfo = NodeInfo()
    @State var urlstr = ""
    @State private var currentTimeStr = ""
    @State private var launchTimeStr = ""
    @State private var nodeInfoRealized = false
    
    var body: some View {
      NavigationView {
        HStack {
          
            VStack(alignment: .leading) {
                if (self.nodeInfoRealized) {
                    HStack {
                        Text("Node name:")
                        Text(currNodeInfo.name)
                    }
                    HStack {
                        Text("Node version:")
                        Text(currNodeInfo.appVersion)
                    }
                    HStack {
                        Text("Headers height:")
                        Text(String(currNodeInfo.headersHeight ?? 0))
                    }
                    HStack {
                        Text("Full height:")
                        Text(String(currNodeInfo.fullHeight ?? 0))
                    }
                    HStack {
                        Text("Current Time:")
                        Text(self.currentTimeStr)
                    }
                    HStack {
                        Text("Launch Time:")
                        Text(self.launchTimeStr)
                    }
                    HStack {
                        Text("Peers Count:")
                        Text(currNodeInfo.peersCount!.description)
                    }
                    HStack {
                        Text("Is Mining?")
                        Text(currNodeInfo.isMining!.description)
                    }
                } else {
                    Text("Gathering node info...")
                }
            }
        }
      }.onAppear(perform: loadNodeInfoDetail)
        .navigationViewStyle(StackNavigationViewStyle())    }
    
    func loadNodeInfoDetail() {
        self.manager.getInfo(urlstr, completionHandler: { (result: NodeInfo)  in
               self.currNodeInfo = result
               let ctime = Date(timeIntervalSince1970: Double(self.currNodeInfo.currentTime!)/Double(1000))
               let dateFormatter = DateFormatter()
               dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
               dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
               dateFormatter.timeZone = .current
               self.currentTimeStr = dateFormatter.string(from: ctime)

               let ltime = Date(timeIntervalSince1970: Double(self.currNodeInfo.launchTime!)/Double(1000))
               self.launchTimeStr = dateFormatter.string(from: ltime)
               self.nodeInfoRealized.toggle()
            })
    }
}

struct NodeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NodeInfoView()
    }
}
