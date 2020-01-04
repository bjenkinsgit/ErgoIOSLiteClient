import Foundation
import SwiftUI
import Combine

public struct MyPaymentRequest: Codable {
    public var address: ErgoAddress
    public var value: Int64
}

public struct TransactionResponse: Codable {
    public var transactionId: String
}

class HttpAuth: ObservableObject {

    @Published var walletBalance: Int64 = 0
    @Published var isOnline = false
    @Published var tranzId: String = ""
    @Published var error_code = 0
    @Published var error_reason = ""
    @Published var error_detail = ""
    @Published var showingPaymentErrorAlert = false
    @Published var ergoTransaction = ErgoTransaction()

    func getBal(_ urlstr: String, _ api_key: String) {
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_balance_get) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(api_key, forHTTPHeaderField: "api_key")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let resData = try! JSONDecoder().decode(BalancesSnapshot.self, from: data)
            DispatchQueue.main.async {
                self.isOnline = true
                self.walletBalance = resData.balance
            }
            print(data)
        }.resume()
    }

    func getWalletTranzById(_ urlstr: String, _ api_key: String, _ tranzid: String, completionHandler: @escaping(ErgoTransaction) -> Void) {
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_tranz_by_id_get+"?id=\(tranzid)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(api_key, forHTTPHeaderField: "api_key")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
 //           let resData = try! JSONDecoder().decode(String.self, from: data)
            if let resData = try? JSONDecoder().decode(ErgoTransaction.self, from: data) {
                DispatchQueue.main.async {
                    completionHandler(resData)
                    print(resData)
                }
            } else if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
               print(responseERROR)
               DispatchQueue.main.async {
                  self.showingPaymentErrorAlert = true
                  self.error_reason = responseERROR.reason
                  self.error_detail = responseERROR.detail
                  self.error_code = responseERROR.error
               }
            }
        }.resume()
    }

    func sendPaymentRequest(_ urlstr: String, _ api_key: String, _ toAddress: String, _ amt: Int64,
                            completionHandler: @escaping(String) -> Void) {
         guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_send_payment_post) else { return }
        let pr = [PaymentRequest(address: toAddress,value: amt)]
        let jsonData = try! JSONEncoder().encode(pr)
//        let json: [[String: Any]] = [["address":toAddress,"value":amt]]
//        let jsonString = String(data: jsonData, encoding: .utf8)!
//         let jsonData = try? JSONSerialization.data(withJSONObject: json)
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.httpBody = jsonData
         request.setValue("application/json", forHTTPHeaderField: "accept")
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue(api_key, forHTTPHeaderField: "api_key")
        
//     open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

         URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            if let responseJSON = try? JSONDecoder().decode(String.self, from: data)  {
                print(responseJSON)
                DispatchQueue.main.async {
                    self.tranzId = responseJSON
                    completionHandler(responseJSON)
                }
            } else if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
               print(responseERROR)
               DispatchQueue.main.async {
                  self.showingPaymentErrorAlert = true
                  self.error_reason = responseERROR.reason
                  self.error_detail = responseERROR.detail
                  self.error_code = responseERROR.error
               }
            }
         }.resume()
     }



}
