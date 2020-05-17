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
    @Published var isWalletInitialized = false
    @Published var isWalletUnlocked = false
    @Published var walletAddresses: [String] = []

    func handle(_ error: Error) {
        switch error {
        // Matching against a group of offline-related errors:
        case URLError.notConnectedToInternet,
             URLError.networkConnectionLost,
             URLError.cannotLoadFromNetwork:
            self.isOnline = false
            self.error_reason = "Network Error"
            self.error_detail = error.localizedDescription
            let urlerror = error as! URLError
            self.error_code = urlerror.errorCode
            self.showingPaymentErrorAlert = true
        case URLError.appTransportSecurityRequiresSecureConnection:
            self.isOnline = false
            self.error_reason = "URLError"
            self.error_detail = error.localizedDescription + "  Please change the 'Account Settings' ergo URL to use either https or to use an IP address directly."
            self.error_code = -1022
            self.showingPaymentErrorAlert = true
        default:
            self.isOnline = false
            self.error_reason = "URLError"
            self.error_detail = error.localizedDescription + "  Network error trying to reach the ERGO url node specified in 'Account Settings'.  Please check to make sure you a) have network connectivity and b) the ability to get to the ERGO url."
            self.error_code = 500
            self.showingPaymentErrorAlert = true
        }
    }
    func getBal(_ urlstr: String, _ api_key: String) {
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_balance_get) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(api_key, forHTTPHeaderField: "api_key")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let resError = error as! URLError
                
                DispatchQueue.main.async {
                    self.handle(resError)
                }
                return
            }
            if let resData = try? JSONDecoder().decode(BalancesSnapshot.self, from: data) {
                DispatchQueue.main.async {
                    self.isOnline = true
                    self.walletBalance = resData.balance
                }
            } else if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
               print(responseERROR)
               DispatchQueue.main.async {
                  self.error_reason = responseERROR.reason
                  self.error_detail = responseERROR.detail
                  self.error_code = responseERROR.error
                  self.walletBalance = 0
               }
            }
        }.resume()
    }

    func getWalletStatus(_ urlstr: String, _ api_key: String, completionHandler: @escaping(Bool) -> Void)
    {
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_status_get) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(api_key, forHTTPHeaderField: "api_key")
        self.error_reason = ""
        self.error_detail = ""
        self.error_code = 0

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let resError = error as! URLError
                
                DispatchQueue.main.async {
                    self.handle(resError)
                    completionHandler(false)
                }
                return
            }
            if let walletStatus = try? JSONDecoder().decode(WalletStatus.self, from: data) {
                DispatchQueue.main.async {
                    self.isWalletInitialized = walletStatus.isInitialized
                    self.isWalletUnlocked    = walletStatus.isUnlocked
                    completionHandler(walletStatus.isUnlocked)
                }
            } else if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
//               print(responseERROR)
               DispatchQueue.main.async {
                  if (responseERROR.detail.contains("Wallet not initialized")) {
                    self.isWalletInitialized = false
                    self.isWalletUnlocked = false
                  } else {
                    self.error_reason = responseERROR.reason
                    self.error_detail = responseERROR.detail
                    self.error_code = responseERROR.error
                }
                  self.walletBalance = 0
                  completionHandler(false)
               }
            }
//            print(data)
        }.resume()
    }

    func getInfo(_ urlstr: String, completionHandler: @escaping(NodeInfo) -> Void)
    {
        if (urlstr == "") { return }
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.info_get) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        self.error_reason = ""
        self.error_detail = ""
        self.error_code = 0

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let resError = error as! URLError
                
                DispatchQueue.main.async {
                    self.handle(resError)
                }
                return
            }
            if let resData = try? JSONDecoder().decode(NodeInfo.self, from: data) {
//                print(resData)
                DispatchQueue.main.async {
                    self.isOnline = true
                    completionHandler(resData)
                }
            } else
                if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
  //             print(responseERROR)
               DispatchQueue.main.async {
                  self.error_reason = responseERROR.reason
                  self.error_detail = responseERROR.detail
                  self.error_code = responseERROR.error
               }
                } else {
                    print("Woah, don't know what happened in the getInfo() method...")
                    print(data)
                }
        }.resume()
    }
    
        func getWalletAddresses(_ urlstr: String, _ api_key: String, completionHandler: @escaping([String]) -> Void)
        {
            guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_addresses) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue(api_key, forHTTPHeaderField: "api_key")
            self.error_reason = ""
            self.error_detail = ""
            self.error_code = 0

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    let resError = error as! URLError
                    
                    DispatchQueue.main.async {
                        self.handle(resError)
                    }
                    return
                }
                if let resData = try? JSONDecoder().decode([String].self, from: data) {
 //                   print(resData)
                    DispatchQueue.main.async {
                         completionHandler(resData)
                    }
                } else
                    if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
      //             print(responseERROR)
                   DispatchQueue.main.async {
                      self.error_reason = responseERROR.reason
                      self.error_detail = responseERROR.detail
                      self.error_code = responseERROR.error
                      //self.showingPaymentErrorAlert = true
                   }
                    } else {
                        print("Woah, don't know what happened in the getWalletAddresses() method...")
                        print(data)
                    }
            }.resume()
        }


    func getWalletTranzById(_ urlstr: String, _ api_key: String, _ tranzid: String, completionHandler: @escaping(ErgoTransaction) -> Void)
    {
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_tranz_by_id_get+"?id=\(tranzid)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(api_key, forHTTPHeaderField: "api_key")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let resError = error as! URLError
                
                DispatchQueue.main.async {
                    self.handle(resError)
                }
                return
            }
 //           let resData = try! JSONDecoder().decode(String.self, from: data)
            if let resData = try? JSONDecoder().decode(ErgoTransaction.self, from: data) {
                print(resData)
                DispatchQueue.main.async {
                    completionHandler(resData)
 //                   print(resData)
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

    func unlockWalletPost(_ urlstr: String, _ api_key: String,_ api_key_password: String, completionHandler: @escaping(String) -> Void) {
        guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_unlock_post) else { return }
        let wur = WalletUnlockRequest(pass: api_key_password)
        let jsonData = try! JSONEncoder().encode(wur)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(api_key, forHTTPHeaderField: "api_key")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
           guard let data = data, error == nil else {
               let resError = error as! URLError
               
               DispatchQueue.main.async {
                   self.handle(resError)
               }
               return
           }
           if let responseJSON = try? JSONDecoder().decode(String.self, from: data)  {
               print("Wallet unlock is: "+responseJSON)
               DispatchQueue.main.async {
                   self.tranzId = responseJSON
                   completionHandler("OK")
               }
           } else if let responseERROR = try? JSONDecoder().decode(ApiError.self, from: data)  {
              print(responseERROR)
              DispatchQueue.main.async {
                 self.showingPaymentErrorAlert = true
                 self.error_reason = responseERROR.reason
                self.error_detail = responseERROR.detail.contains("Tag mismatch") ? "Bad auth key password--check Account Settingss" : responseERROR.detail
                 self.error_code = responseERROR.error
                self.walletBalance = 0
              }
           }
        }.resume()
    }
    
    func sendPaymentRequest(_ urlstr: String, _ api_key: String, _ toAddress: String, _ amt: Int64,
                            _ api_key_password: String,
                            completionHandler: @escaping(String) -> Void) {
         guard let url = URL(string: urlstr+ERGO_API_ROUTES.wallet_send_payment_post) else { return }
        let pr = [PaymentRequest(address: toAddress,value: amt)]
        let jsonData = try! JSONEncoder().encode(pr)
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.httpBody = jsonData
         request.setValue("application/json", forHTTPHeaderField: "accept")
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue(api_key, forHTTPHeaderField: "api_key")
        
         URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let resError = error as! URLError
                
                DispatchQueue.main.async {
                    self.handle(resError)
                }
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
                  self.error_code = responseERROR.error
                  let notEnoughBoxesStr = "No enough boxes to assemble a transaction"
                  let walletIsLockedStr = "Wallet is locked"
                  let notEnoughBoxesResp = "Your payment is in process.  However...there is not enough transaction activity yet to provide a transaction ID at this time..."
                  if (responseERROR.detail.contains(notEnoughBoxesStr) || responseERROR.detail.contains(walletIsLockedStr) ) {
                    if responseERROR.detail.contains(notEnoughBoxesStr) {
                        print(responseERROR.detail)
                        self.error_detail = notEnoughBoxesResp
                    } else {
                        self.error_detail = walletIsLockedStr
                    }
                    }
                   else {
                    self.error_detail = responseERROR.detail
                  }
               }
            }
         }.resume()
     }
}
