import UIKit

public struct Parameters: Codable {
    public var height: Int
    public var storageFeeFactor: Int
    public var minValuePerByte: Int
    public var maxBlockSize: Int
    public var maxBlockCost: Int
    public var blockVersion: Int
    public var tokenAccessCost: Int
    public var inputCost: Int
    public var dataInputCost: Int
    public var outputCost: Int
}

public struct NI: Codable {
    public enum StateType: String, Codable {
        case digest = "digest"
        case utxo = "utxo"
    }
    public var name: String
    public var appVersion: String
    public var fullHeight: Int
    public var headersHeight: Int
    public var bestFullHeaderId: String
    public var previousFullHeaderId: String
    public var bestHeaderId: String
    public var stateRoot: String
    public var stateType: StateType
    public var stateVersion: String
    public var isMining: Bool
    public var peersCount: Int
    public var unconfirmedCount: Int
    public var difficulty: Int
    public var currentTime: Int
    public var launchTime: Int
    public var headersScore: Int
    public var fullBlocksScore: Int
    public var genesisBlockId: String
    public var parameters: Parameters
}

let data = """
{
  "currentTime" : 1580141301468,
  "name" : "bart-ergo-testnet-cuda-node",
  "stateType" : "utxo",
   "difficulty" : 3177775104,
   "bestFullHeaderId" : "0003695a32e8fc2ca329ef4b36c50b76ad1f06858fc92bacabd58f0e45163b32",
   "bestHeaderId" : "0003695a32e8fc2ca329ef4b36c50b76ad1f06858fc92bacabd58f0e45163b32",
   "peersCount" : 14,
   "unconfirmedCount" : 0,
   "appVersion" : "3.2.0",
   "stateRoot" : "7e8a2c929a239697266fc65ab9a756cf4c8499cab3a7853a4e8ce172fb31a88814",
   "genesisBlockId" : "f654fccd73b388177a7363788296c900475590e08cf8e945beb721064ebc3658",
   "previousFullHeaderId" : "609332ba2630e03a7f4cee7e601370e94ec34043b5beb9a875da8690c69377fb",
   "fullHeight" : 92727,
   "headersHeight" : 92727,
   "stateVersion" : "0003695a32e8fc2ca329ef4b36c50b76ad1f06858fc92bacabd58f0e45163b32",
   "fullBlocksScore" : 105243035398144,
   "launchTime" : 1579813541933,
   "headersScore" : 105243035398144,
   "parameters" : {
     "outputCost" : 100,
     "tokenAccessCost" : 100,
     "maxBlockCost" : 1126822,
     "height" : 92160,
     "maxBlockSize" : 524288,
     "dataInputCost" : 100,
     "blockVersion" : 1,
     "inputCost" : 2000,
     "storageFeeFactor" : 1250000,
     "minValuePerByte" : 360
   },
   "isMining" : true
}
""".data(using: .utf8)!

if let responseERROR = try? JSONDecoder().decode(NI.self, from: data)  {
    print("OK DECODED!")
} else {
    print("NOT decoded...")
}


