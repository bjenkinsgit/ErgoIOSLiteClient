import UIKit

public struct Parameters: Decodable {
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

public enum StateType: String, Decodable {
    case digest = "digest"
    case utxo = "utxo"
}

public struct NI: Decodable {
    
    public var currentTime: UInt64?
    public var name: String?
    public var appVersion: String?
    public var fullHeight: UInt64?
    public var headersHeight: UInt64?
    public var bestFullHeaderId: String?
    public var previousFullHeaderId: String?
    public var bestHeaderId: String?
    public var stateRoot: String?
    public var stateType: StateType?
    public var stateVersion: String?
    public var peersCount: Int?
    public var unconfirmedCount: Int?
    public var difficulty: UInt64?
    public var launchTime: Int?
    public var headersScore: Decimal?
    public var fullBlocksScore: Decimal?
    public var genesisBlockId: String?
    public var parameters: Parameters?
    public var isMining: Bool?
}

let data_mainnet = """
{
  "currentTime" : 1584304502934,
"name" : "usa-mid-atlantic-mainnet-ergo-node",
"stateType" : "utxo",
"difficulty" : 201025944289280,
"bestFullHeaderId" : "3f9ff2490f2653a4018e2051c6800c947dcf94bd476833eaa822fc129ba28128",
"bestHeaderId" : "3f9ff2490f2653a4018e2051c6800c947dcf94bd476833eaa822fc129ba28128",
"peersCount" : 10,
"unconfirmedCount" : 0,
"appVersion" : "3.2.0",
"stateRoot" : "cea3942f6162d5519b598e433fcc9d22148216b72bfa50845d622d48e06a36a515",
"genesisBlockId" : "b0244dfc267baca974a4caee06120321562784303a8a688976ae56170e4d175b",
"previousFullHeaderId" : "8d40b56b3d4e3e162168eaebcd365c0798d89b6d043de234dd4c348649051384",
"fullHeight" : 92727,
"headersHeight" : 92727,
"stateVersion" : "3f9ff2490f2653a4018e2051c6800c947dcf94bd476833eaa822fc129ba28128",
"fullBlocksScore" : 28373612035454271488,
"launchTime" : 1584303810091,
"headersScore" : 28373612035454271488,
"parameters" : {
  "outputCost" : 100,
  "tokenAccessCost" : 100,
  "maxBlockCost" : 1232383,
  "height" : 185344,
  "maxBlockSize" : 556539,
  "dataInputCost" : 100,
  "blockVersion" : 1,
  "inputCost" : 2000,
  "storageFeeFactor" : 1250000,
  "minValuePerByte" : 360
},

  "isMining" : true
}
""".data(using: .utf8)!

let data = """
{
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
   "currentTime" : 1580141301468,
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

let decoded = JSONDecoder().decode(NI.self, from: data_mainnet)

if let responseERROR = try? JSONDecoder().decode(NI.self, from: data_mainnet)  {
    print("OK DECODED!")
} else {
    print("NOT decoded...")
}


