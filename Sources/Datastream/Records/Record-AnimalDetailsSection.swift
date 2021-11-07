//
//  Record-AnimalDetailsSection.swift
//  
//
//  Created by Ben Barnett on 05/11/2021.
//

import Foundation

public struct AnimalIdentityRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.animalIdentity]
    }

    public var regionNumber: Int
    public var producerNumber: Int
    public var herdCode: Int
    public var nmrHerdNumber: String {
        return "\(regionNumber)\(producerNumber)\(herdCode)"
    }
    public var liveFlag: Int
    public var lineNumber: String
    public var breedID: Int
    public var identityNumber: String
    public var identityType: IdentityType
    public var pedigreeStatus: PedigreeStatus
    public var hbnAuthenticity: IdentityAuthenticity
    public var earmarkAuthenticity: IdentityAuthenticity
    

    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        regionNumber = try Field(location: 3, length: 2).extractValue(from: content)
        producerNumber = try Field(location: 6, length: 5).extractValue(from: content)
        herdCode = try Field(location: 12, length: 2).extractValue(from: content)
        liveFlag = try Field(location: 15, length: 1).extractValue(from: content)
        lineNumber = try Field(location: 17, length: 4).extractValue(from: content)
        breedID = try Field(location: 22, length: 2).extractValue(from: content)
        identityNumber = try Field(location: 25, length: 12).extractValue(from: content)
        identityType = try Field(location: 38, length: 1).extractValue(from: content)
        pedigreeStatus = try Field(location: 40, length: 1).extractValue(from: content)
        hbnAuthenticity = try Field(location: 42, length: 1).extractValue(from: content)
        earmarkAuthenticity = try Field(location: 44, length: 1).extractValue(from: content)
    }
}

public struct AnimalOtherDetailsRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.animalOtherDetails]
    }

    public var alternativeBreed: Int
    public var alternativeIdentity: String
    public var birthDate: Date
    public var isYoungstock: Bool
    public var entryDate: Date
    public var exitDate: Date?
    public var leavingReason: LeavingReason
    public var classChangeDate: Date?
    

    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        alternativeBreed = try Field(location: 3, length: 2).extractValue(from: content)
        alternativeIdentity = try Field(location: 6, length: 12).extractValue(from: content)
        birthDate = try Field(location: 19, length: 6).extractValue(from: content)
        isYoungstock = try Field(location: 26, length: 1).extractValue(from: content)
        entryDate = try Field(location: 28, length: 6).extractValue(from: content)
        exitDate = try Field(location: 35, length: 6).extractValue(from: content)
        leavingReason = try Field(location: 42, length: 1).extractValue(from: content)
        classChangeDate = try Field(location: 44, length: 6).extractValue(from: content)
        
    }
}

public struct AnimalNameRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.animalName]
    }

    public var shortName: String
    public var longName: String
    

    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        shortName = try Field(location: 3, length: 20).extractValue(from: content)
        longName = try Field(location: 24, length: 40).extractValue(from: content)
    }
}

public struct AnimalParentsRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.animalSireDam]
    }

    public var sireBreed: Int
    public var sireIdentity: String
    public var sireIdentityType: IdentityType
    public var damBreed: Int
    public var damIdentity: String
    public var damIdentityType: IdentityType
    public var damPedigreeStatus: PedigreeStatus
    public var damIdentityAuthenticity: IdentityAuthenticity
    
    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        sireBreed = try Field(location: 3, length: 2).extractValue(from: content)
        sireIdentity = try Field(location: 6, length: 12).extractValue(from: content)
        sireIdentityType = try Field(location: 19, length: 1).extractValue(from: content)
        damBreed = try Field(location: 23, length: 2).extractValue(from: content)
        damIdentity = try Field(location: 26, length: 12).extractValue(from: content)
        damIdentityType = try Field(location: 39, length: 1).extractValue(from: content)
        damPedigreeStatus = try Field(location: 41, length: 1).extractValue(from: content)
        damIdentityAuthenticity = try Field(location: 43, length: 1).extractValue(from: content)
    }
}

public struct PTARecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.animalPTA, .animalPTA2, .animalPTA3, .animalPTA4]
    }

    public var evaluationGroup: EvaluationGroup
    public var evaluationSource: EvaluationSource
    public var evaluationDate: Date
    public var ptaMilkKG: Int
    public var ptaFatKG: Double
    public var ptaProteinKG: Double
    public var ptaFatPct: Double
    public var ptaProteinPct: Double
    public var reliability: Int
    
    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        evaluationGroup = try Field(location: 3, length: 2).extractValue(from: content)
        evaluationSource = try Field(location: 6, length: 2).extractValue(from: content)
        evaluationDate = try Field(location: 9, length: 6).extractValue(from: content)
        ptaMilkKG = try Field(location: 16, length: 5).extractValue(from: content)
        ptaFatKG = try Field(location: 22, length: 5).extractValue(from: content, divisor: 10)
        ptaProteinKG = try Field(location: 28, length: 5).extractValue(from: content, divisor: 10)
        ptaFatPct = try Field(location: 34, length: 5).extractValue(from: content, divisor: 100)
        ptaProteinPct = try Field(location: 40, length: 5).extractValue(from: content, divisor: 100)
        reliability = try Field(location: 46, length: 2).extractValue(from: content)
    }
}
