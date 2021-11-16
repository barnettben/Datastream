//
//  Record-BreedSection.swift
//  
//
//  Created by Ben Barnett on 15/11/2021.
//

import Foundation

public struct BreedPart1Record: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.breedRecord1]
    }

    public var code: Int
    public var equivalent: Int
    public var name: String
    public var abbreviation: String
    public var gestationPeriod: Int
    public var minDailyYield: Double
    public var lowMilkQuery: Double
    public var highMilkQuery: Double
    public var maxDailyYield: Double

    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        code = try Field(location: 3, length: 2).extractValue(from: content)
        equivalent = try Field(location: 6, length: 2).extractValue(from: content)
        name = try Field(location: 9, length: 25).extractValue(from: content)
        abbreviation = try Field(location: 35, length: 2).extractValue(from: content)
        gestationPeriod = try Field(location: 38, length: 3).extractValue(from: content)
        minDailyYield = try Field(location: 42, length: 3, divisor: 10).extractValue(from: content)
        lowMilkQuery = try Field(location: 46, length: 3, divisor: 10).extractValue(from: content)
        highMilkQuery = try Field(location: 50, length: 3, divisor: 10).extractValue(from: content)
        maxDailyYield = try Field(location: 54, length: 3, divisor: 10).extractValue(from: content)
    }
}

public struct BreedPart2Record: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.breedRecord2]
    }

    public var minFatPct: Double
    public var lowFatQuery: Double
    public var highFatQuery: Double
    public var maxFatPct: Double
    public var minProteinPct: Double
    public var lowProteinQuery: Double
    public var highProteinQuery: Double
    public var maxProteinPct: Double
    public var minLactosePct: Double
    public var lowLactoseQuery: Double
    public var highLactoseQuery: Double
    public var maxLactosePct: Double

    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        minFatPct = try Field(location: 3, length: 4, divisor: 100).extractValue(from: content)
        lowFatQuery = try Field(location: 8, length: 4, divisor: 100).extractValue(from: content)
        highFatQuery = try Field(location: 13, length: 4, divisor: 100).extractValue(from: content)
        maxFatPct = try Field(location: 18, length: 4, divisor: 100).extractValue(from: content)
        minProteinPct = try Field(location: 23, length: 4, divisor: 100).extractValue(from: content)
        lowProteinQuery = try Field(location: 28, length: 4, divisor: 100).extractValue(from: content)
        highProteinQuery = try Field(location: 33, length: 4, divisor: 100).extractValue(from: content)
        maxProteinPct = try Field(location: 38, length: 4, divisor: 100).extractValue(from: content)
        minLactosePct = try Field(location: 43, length: 4, divisor: 100).extractValue(from: content)
        lowLactoseQuery = try Field(location: 48, length: 4, divisor: 100).extractValue(from: content)
        highLactoseQuery = try Field(location: 53, length: 4, divisor: 100).extractValue(from: content)
        maxLactosePct = try Field(location: 58, length: 4, divisor: 100).extractValue(from: content)
    }
}

public struct BreedPart3Record: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.breedRecord3]
    }

    public var high305dYieldQuery: Int
    public var max305dYield: Int
    public var highNaturalYieldQuery: Int
    public var maxNaturalYield: Int

    public init(string content: String) throws {
        descriptor = try Field.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        high305dYieldQuery = try Field(location: 3, length: 5).extractValue(from: content)
        max305dYield = try Field(location: 9, length: 5).extractValue(from: content)
        highNaturalYieldQuery = try Field(location: 15, length: 5).extractValue(from: content)
        maxNaturalYield = try Field(location: 21, length: 5).extractValue(from: content)
    }
}
