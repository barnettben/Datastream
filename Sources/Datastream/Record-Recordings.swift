//
//  File.swift
//  
//
//  Created by Ben Barnett on 24/10/2021.
//

import Foundation

public struct RecordingPart1: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.recordingPart1]
    }

    public var recordingDate: Date
    public var weighingSequence: Int
    public var totalAnimals: Int
    public var cowsInMilk: Int
    public var cows3xMilked: Int
    public var herdTotalMilk: Double
    public var herdTotalFat: Double
    public var herdTotalProtein: Double
    public var herdTotalLactose: Double
    public var yieldDifferenceCode: DifferenceCode
    public var missedWeighing: Bool
    public var printEligible: Bool

    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        self.recordingDate = try Field(location: 3, length: 6).extractValue(from: content)
        self.weighingSequence = try Field(location: 10, length: 2).extractValue(from: content)
        self.totalAnimals = try Field(location: 16, length: 4).extractValue(from: content)
        self.cowsInMilk = try Field(location: 21, length: 4).extractValue(from: content)
        self.cows3xMilked = try Field(location: 26, length: 4).extractValue(from: content)
        self.herdTotalMilk = try Field(location: 31, length: 6).extractValue(from: content, divisor: 10)
        self.herdTotalFat = try Field(location: 38, length: 7).extractValue(from: content, divisor: 10000)
        self.herdTotalProtein = try Field(location: 46, length: 7).extractValue(from: content, divisor: 1000)
        self.herdTotalLactose = try Field(location: 54, length: 7).extractValue(from: content, divisor: 10000)
        self.yieldDifferenceCode = try Field(location: 62, length: 1).extractValue(from: content)
        self.missedWeighing = try Field(location: 64, length: 1).extractValue(from: content)
        self.printEligible = try Field(location: 66, length: 1).extractValue(from: content)
    }
}

public struct RecordingPart2: Record {
    public var descriptor: RecordDescriptor
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableDescriptors: [RecordDescriptor] {
        return [.recordingPart2]
    }

    public var bulkYield: Int
    public var bulkFatPct: Double
    public var bulkProteinPct: Double
    public var bulkLactosePct: Double
    public var herdProductionBase: Int
    public var bulkCellCount: Int

    public init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        Self.assertCanRepresentDescriptor(descriptor)
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)
        
        self.bulkYield = try Field(location: 3, length: 5).extractValue(from: content)
        self.bulkFatPct = try Field(location: 9, length: 4).extractValue(from: content)
        self.bulkProteinPct = try Field(location: 14, length: 4).extractValue(from: content)
        self.bulkLactosePct = try Field(location: 19, length: 4).extractValue(from: content)
        self.herdProductionBase = try Field(location: 24, length: 6).extractValue(from: content)
        self.bulkCellCount = try Field(location: 51, length: 4).extractValue(from: content)
    }
}
