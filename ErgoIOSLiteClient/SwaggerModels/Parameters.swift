//
// Parameters.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


public struct Parameters: Codable {


    /** Height when current parameters were considered(not actual height). Can be &#x27;0&#x27; if state is empty */
    public var height: Int

    /** Storage fee coefficient (per byte per storage period ~4 years) */
    public var storageFeeFactor: Int

    /** Minimum value per byte of an output */
    public var minValuePerByte: Int

    /** Maximum block size (in bytes) */
    public var maxBlockSize: Int

    /** Maximum cumulative computational complexity of input scipts in block transactions */
    public var maxBlockCost: Int

    public var blockVersion: Int

    /** Validation cost of a single token */
    public var tokenAccessCost: Int

    /** Validation cost per one transaction input */
    public var inputCost: Int

    /** Validation cost per one data input */
    public var dataInputCost: Int

    /** Validation cost per one transaction output */
    public var outputCost: Int
    public init(height: Int, storageFeeFactor: Int, minValuePerByte: Int, maxBlockSize: Int, maxBlockCost: Int, blockVersion: Int, tokenAccessCost: Int, inputCost: Int, dataInputCost: Int, outputCost: Int) {
        self.height = height
        self.storageFeeFactor = storageFeeFactor
        self.minValuePerByte = minValuePerByte
        self.maxBlockSize = maxBlockSize
        self.maxBlockCost = maxBlockCost
        self.blockVersion = blockVersion
        self.tokenAccessCost = tokenAccessCost
        self.inputCost = inputCost
        self.dataInputCost = dataInputCost
        self.outputCost = outputCost
    }

}
