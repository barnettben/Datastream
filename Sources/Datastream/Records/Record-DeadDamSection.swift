//
//  Record-DeadDamSection.swift
//  
//
//  Created by Ben Barnett on 14/11/2021.
//

import Foundation

public struct DeadDamRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.deadDamDetails]
    }
    
    public var breed: Int
    public var identity: String
    public var identityType: IdentityType
    public var identityAuthenticity: ItemAuthenticity
    public var pedigreeStatus: PedigreeStatus
    public var longName: String
    
    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        breed = try Field(location: 3, length: 2).extractValue(from: content)
        identity = try Field(location: 6, length: 12).extractValue(from: content)
        identityType = try Field(location: 19, length: 1).extractValue(from: content)
        identityAuthenticity = try Field(location: 23, length: 1).extractValue(from: content)
        pedigreeStatus = try Field(location: 21, length: 1).extractValue(from: content)
        longName = try Field(location: 28, length: 40).extractValue(from: content)
    }
}
