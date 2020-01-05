//
//  Utils.swift
//  BioMetric1
//
//  Created by Bart Jenkins on 12/25/19.
//  Copyright © 2019 Bart Jenkins. All rights reserved.
//

import SwiftUI

struct ERGO_API_ROUTES {
  static let wallet_balance_get = "/wallet/balances"
  static let wallet_unlock_get  = "/wallet/unlock"
  static let wallet_send_payment_post  = "/wallet/payment/send"
  static let wallet_tranz_by_id_get = "/wallet/transactionById"
}

let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

extension Double {

    func getStringValue(withFloatingPoints points: Int = 0) -> String {
        let valDouble = modf(self)
        let fractionalVal = (valDouble.1)
        if fractionalVal > 0 {
            return String(format: "%.*f", points, self)
        }
        return String(format: "%.0f", self)
    }
}

struct ClearButton: ViewModifier
{
    @Binding var text: String

    public func body(content: Content) -> some View
    {
        ZStack(alignment: .trailing)
        {
            content

            if !text.isEmpty
            {
                Button(action:
                {
                    self.text = ""
                })
                {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}