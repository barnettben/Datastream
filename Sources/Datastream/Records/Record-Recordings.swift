//
//  File.swift
//  
//
//  Created by Ben Barnett on 24/10/2021.
//

import Foundation

public struct RecordingPart1: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
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
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        self.recordingDate = try Field(location: 3, length: 6).extractValue(from: content)
        self.weighingSequence = try Field(location: 10, length: 2).extractValue(from: content)
        self.totalAnimals = try Field(location: 16, length: 4).extractValue(from: content)
        self.cowsInMilk = try Field(location: 21, length: 4).extractValue(from: content)
        self.cows3xMilked = try Field(location: 26, length: 4).extractValue(from: content)
        self.herdTotalMilk = try Field(location: 31, length: 6, divisor: 10).extractValue(from: content)
        self.herdTotalFat = try Field(location: 38, length: 7, divisor: 10000).extractValue(from: content)
        self.herdTotalProtein = try Field(location: 46, length: 7, divisor: 1000).extractValue(from: content)
        self.herdTotalLactose = try Field(location: 54, length: 7, divisor: 10000).extractValue(from: content)
        self.yieldDifferenceCode = try Field(location: 62, length: 1).extractValue(from: content)
        self.missedWeighing = try Field(location: 64, length: 1).extractValue(from: content)
        self.printEligible = try Field(location: 66, length: 1).extractValue(from: content)
    }
}

public enum DifferenceCode: Int {
    case notDefined       = 0
    case noSampleTaken    = 1
    case yieldsMissing    = 2
    case notReceivedAtLab = 3
    case noSampleTaken2   = 4
    case spilt            = 5
    case spoiled          = 6
    case sediment         = 7
    
    /// Unknown reason
    ///
    /// This has been found in real-life files, but is not present
    /// in the specification.
    case unknown          = 8
}

// MARK: -

public struct RecordingPart2: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.recordingPart2]
    }

    public var bulkYield: Int
    public var bulkFatPct: Double
    public var bulkProteinPct: Double
    public var bulkLactosePct: Double
    public var herdProductionBase: Int
    public var bulkCellCount: Int

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        self.bulkYield = try Field(location: 3, length: 5).extractValue(from: content)
        self.bulkFatPct = try Field(location: 9, length: 4, divisor: 100).extractValue(from: content)
        self.bulkProteinPct = try Field(location: 14, length: 4, divisor: 100).extractValue(from: content)
        self.bulkLactosePct = try Field(location: 19, length: 4, divisor: 100).extractValue(from: content)
        self.herdProductionBase = try Field(location: 24, length: 6).extractValue(from: content)
        self.bulkCellCount = try Field(location: 51, length: 4).extractValue(from: content)
    }
}

