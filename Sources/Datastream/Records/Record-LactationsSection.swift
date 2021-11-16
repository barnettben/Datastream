//
//  Record-LactationsSection.swift
//  
//
//  Created by Ben Barnett on 12/11/2021.
//

import Foundation

// NOTE: L0 (Lactation Section Leader) is the same as record S0

public struct CompletedLactationRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.lactationFixedDetails]
    }
    
    public var aliveFlag: Int
    public var lineNumber: String
    public var lactationNumber: Int
    public var estimatedLactationNumber: Int
    public var breedCode: Int
    public var totalMaleCalves: Int
    public var totalFemaleCalves: Int
    public var totalDeadCalves: Int
    public var numberOfDryDays: Int
    public var numberOfServices: Int
    public var missedRecordings: Int
    public var seasonalityAdjustment: Int
    public var financialValue: Int
    public var productionIndex: Int
    public var productionBase: Double
    public var numberOfTimesLame: Int
    public var numberOfTimesMastitis: Int
    public var numberOfTimesSick: Int
    
    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        aliveFlag = try Field(location: 3, length: 1).extractValue(from: content)
        lineNumber = try Field(location: 5, length: 4).extractValue(from: content)
        lactationNumber = try Field(location: 10, length: 2).extractValue(from: content)
        breedCode = try Field(location: 13, length: 2).extractValue(from: content)
        totalMaleCalves = try Field(location: 16, length: 1).extractValue(from: content)
        totalFemaleCalves = try Field(location: 18, length: 1).extractValue(from: content)
        totalDeadCalves = try Field(location: 20, length: 1).extractValue(from: content)
        numberOfDryDays = try Field(location: 22, length: 3).extractValue(from: content)
        estimatedLactationNumber = try Field(location: 26, length: 2).extractValue(from: content)
        numberOfServices = try Field(location: 29, length: 2).extractValue(from: content)
        missedRecordings = try Field(location: 32, length: 2).extractValue(from: content)
        seasonalityAdjustment = try Field(location: 35, length: 4).extractValue(from: content)
        financialValue = try Field(location: 40, length: 4).extractValue(from: content)
        productionIndex = try Field(location: 45, length: 6).extractValue(from: content)
        productionBase = try Field(location: 52, length: 6, divisor: 100).extractValue(from: content)
        numberOfTimesLame = try Field(location: 59, length: 2).extractValue(from: content)
        numberOfTimesMastitis = try Field(location: 62, length: 2).extractValue(from: content)
        numberOfTimesSick = try Field(location: 65, length: 2).extractValue(from: content)
    }
}

public struct CalvingDetailsRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.calvingDetails]
    }
    
    public var calvingInterval: Int
    public var ageAtCalving: Int
    public var calvingDate: Date
    public var calvingDateAuthenticity: ItemAuthenticity
    public var sireBreed: Int
    public var sireIdentity: String
    public var sireIdentityType: IdentityType
    public var sireIdentityAuthenticity: ItemAuthenticity
    public var calfBreed: Int
    public var calfIdentity: String
    public var calfIdentityType: IdentityType
    public var calfIdentityAuthenticity: ItemAuthenticity
    public var calfSex: Sex?
    
    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        calvingInterval = try Field(location: 3, length: 3).extractValue(from: content)
        ageAtCalving = try Field(location: 7, length: 3).extractValue(from: content)
        calvingDate = try Field(location: 11, length: 6).extractValue(from: content)
        calvingDateAuthenticity = try Field(location: 18, length: 1).extractValue(from: content)
        sireBreed = try Field(location: 20, length: 2).extractValue(from: content)
        sireIdentity = try Field(location: 23, length: 12).extractValue(from: content)
        sireIdentityType = try Field(location: 36, length: 1).extractValue(from: content)
        sireIdentityAuthenticity = try Field(location: 38, length: 1).extractValue(from: content)
        calfBreed = try Field(location: 42, length: 2).extractValue(from: content)
        calfIdentity = try Field(location: 45, length: 12).extractValue(from: content)
        calfIdentityType = try Field(location: 58, length: 1).extractValue(from: content)
        calfIdentityAuthenticity = try Field(location: 60, length: 1).extractValue(from: content)
        calfSex = try Field(location: 62, length: 1).extractValue(from: content)
    }
}

public struct CalvingExtraCalvesRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.calvingPossibleExtraCalves]
    }
    
    public var calf2Breed: Int
    public var calf2Identity: String
    public var calf2IdentityType: IdentityType
    public var calf2IdentityAuthenticity: ItemAuthenticity
    public var calf2Sex: Sex?
    public var calf3Breed: Int
    public var calf3Identity: String
    public var calf3IdentityType: IdentityType
    public var calf3IdentityAuthenticity: ItemAuthenticity
    public var calf3Sex: Sex?
    
    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        calf2Breed = try Field(location: 3, length: 2).extractValue(from: content)
        calf2Identity = try Field(location: 6, length: 12).extractValue(from: content)
        calf2IdentityType = try Field(location: 19, length: 1).extractValue(from: content)
        calf2IdentityAuthenticity = try Field(location: 21, length: 1).extractValue(from: content)
        calf2Sex = try Field(location: 23, length: 1).extractValue(from: content)
        calf3Breed = try Field(location: 25, length: 2).extractValue(from: content)
        calf3Identity = try Field(location: 28, length: 12).extractValue(from: content)
        calf3IdentityType = try Field(location: 41, length: 1).extractValue(from: content)
        calf3IdentityAuthenticity = try Field(location: 43, length: 1).extractValue(from: content)
        calf3Sex = try Field(location: 45, length: 1).extractValue(from: content)
    }
}

public struct LactationTotalsRecord: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.lactation305dTotals, .lactationNaturalTotals]
    }
    
    public var isQualifiedForPublication: Bool
    public var totalAuthenticity: ItemAuthenticity
    public var milkYield: Double
    public var fatYield: Double
    public var proteinYield: Double
    public var lactoseYield: Double
    public var totalDays: Int
    public var total3xDays: Int
    public var startOf3x: Int
    public var lactationEndDate: Date
    public var lactationEndReason: EndReason
    public var numberOfRecordings: Int
    public var averageCellCount: Int
    public var cellsOver200: Int
    
    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        isQualifiedForPublication = try Field(location: 3, length: 1).extractValue(from: content)
        totalAuthenticity = try Field(location: 5, length: 1).extractValue(from: content)
        milkYield = try Field(location: 7, length: 6, divisor: 10).extractValue(from: content)
        fatYield = try Field(location: 14, length: 6, divisor: 100).extractValue(from: content)
        proteinYield = try Field(location: 21, length: 6, divisor: 100).extractValue(from: content)
        lactoseYield = try Field(location: 28, length: 6, divisor: 100).extractValue(from: content)
        totalDays = try Field(location: 35, length: 4, divisor: 10).extractValue(from: content)
        total3xDays = try Field(location: 40, length: 4, divisor: 10).extractValue(from: content)
        startOf3x = try Field(location: 45, length: 4, divisor: 10).extractValue(from: content)
        lactationEndDate = try Field(location: 50, length: 6).extractValue(from: content)
        lactationEndReason = try Field(location: 57, length: 2).extractValue(from: content)
        numberOfRecordings = try Field(location: 60, length: 2).extractValue(from: content)
        averageCellCount = try Field(location: 63, length: 4).extractValue(from: content)
        cellsOver200 = try Field(location: 68, length: 2).extractValue(from: content)
    }
}
