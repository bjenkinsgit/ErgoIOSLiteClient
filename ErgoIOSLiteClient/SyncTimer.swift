//
//  SyncTimer.swift
//  ErgoIOSLiteClient
//
//  Created by Bart Jenkins on 3/8/20.
//  Copyright © 2020 Bart Jenkins. All rights reserved.
//

import Foundation
import Combine

class SyncTimer {
    let currentTimePublisher = Timer.TimerPublisher(interval: 10.0, runLoop: .main, mode: .default)
    let cancellable: AnyCancellable?

    init() {
        self.cancellable = currentTimePublisher.connect() as? AnyCancellable
    }

    deinit {
        self.cancellable?.cancel()
    }
}

