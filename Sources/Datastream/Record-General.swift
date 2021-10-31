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
    public static var representableDescriptors: [RecordDescriptor] {
        return [.address1, .address2, .address3, .address4, .address5]
    }
    
    public var content: String
    
    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        Self.assertCanRepresentDescriptor(descriptor)
        
        self.content = try Field(location: 3, length: 35).extractValue(from: content).trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
