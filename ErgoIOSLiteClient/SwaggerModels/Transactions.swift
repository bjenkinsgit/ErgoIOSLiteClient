//
// ErgoTransaction.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Ergo transaction */
public struct ErgoTransaction: Codable {


    public var id: String?
    public var inputs: [ErgoTransactionInput]
    public var dataInputs: [ErgoTransactionDataInput]
    public var outputs: [ErgoTransactionOutput]
    public var size: Int?
    public var numConfirmations: Int?
    public init(_id: String? = nil, inputs: [ErgoTransactionInput]=[], dataInputs: [ErgoTransactionDataInput]=[], outputs: [ErgoTransactionOutput]=[], size: Int? = nil, numConfirmations: Int? = nil) {
        self.id = _id
        self.inputs = inputs
        self.dataInputs = dataInputs
        self.outputs = outputs
        self.size = size
        self.numConfirmations = numConfirmations
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case inputs
        case dataInputs
        case outputs
        case size
        case numConfirmations
    }

}
