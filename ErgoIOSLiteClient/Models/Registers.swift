//
// Registers.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Ergo box registers */
public struct Registers: Codable {

    public var additionalProperties: [String:String] = [:]

    public subscript(key: String) -> String? {
        get {
            if let value = additionalProperties[key] {
                return value
            }
            return nil
        }

        set {
            additionalProperties[key] = newValue
        }
    }

    // Encodable protocol methods

//    public func encode(to encoder: Encoder) throws {
//
//        var container = encoder.container(keyedBy: String.self)
//
//        try container.encodeMap(additionalProperties)
//    }
//
//    // Decodable protocol methods
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: String.self)
//
//        var nonAdditionalPropertyKeys = Set<String>()
//        additionalProperties = try container.decodeMap(SValue.self, excludedKeys: nonAdditionalPropertyKeys)
//    }


}
