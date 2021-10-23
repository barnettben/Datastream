//
//  Record-General.swift
//  
//
//  Created by Ben Barnett on 21/10/2021.
//

import Foundation

public struct TextRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    
    public var content: String
    
    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)

        self.content = try Field(location: 3, length: 35).extractValue(from: content)
    }
}
