//
//  File.swift
//  
//
//  Created by Ben Barnett on 09/11/2021.
//

import Foundation

public struct NMRNumberRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.statementSectionLeader, .lactationSectionLeader]
    }

    public var region: String
    public var producer: String
    public var herd: String
    public var nmrNumber: String {
        return region + producer + herd
    }

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        region = try Field(location: 3, length: 2).extractValue(from: content)
        producer = try Field(location: 6, length: 5).extractValue(from: content)
        herd = try Field(location: 12, length: 2).extractValue(from: content)
    }
}

public struct CowIDRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.cowIDRecord]
    }

    public var liveFlag: Int
    public var lineNumber: String
    public var isYoungstock: Bool
    public var breedCode: Int
    public var lactationNumber: Int
    public var estimatedLactationNumber: Int
    public var group: Int
    public var lactationStage: LactationStage
    public var lastCalvingDate: Date?
    public var sireBreedCode: Int
    public var sireIdentity: String
    public var sireIdentityType: IdentityType
    public var sireIdentityAuthenticity: ItemAuthenticity
    public var dryDays: Int
    

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        liveFlag = try Field(location: 3, length: 1).extractValue(from: content)
        lineNumber = try Field(location: 5, length: 4).extractValue(from: content)
        isYoungstock = try Field(location: 10, length: 1).extractValue(from: content)
        breedCode = try Field(location: 12, length: 2).extractValue(from: content)
        lactationNumber = try Field(location: 15, length: 2).extractValue(from: content)
        estimatedLactationNumber = try Field(location: 18, length: 2).extractValue(from: content)
        group = try Field(location: 21, length: 2).extractValue(from: content)
        lactationStage = try Field(location: 24, length: 1).extractValue(from: content)
        lastCalvingDate = try Field(location: 26, length: 6).extractValue(from: content)
        sireBreedCode = try Field(location: 33, length: 2).extractValue(from: content)
        sireIdentity = try Field(location: 36, length: 12).extractValue(from: content)
        sireIdentityType = try Field(location: 49, length: 1).extractValue(from: content)
        sireIdentityAuthenticity = try Field(location: 51, length: 1).extractValue(from: content)
        dryDays = try Field(location: 53, length: 3).extractValue(from: content)
    }
}

public struct WeighingRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.eventWeighing]
    }

    public var recordingDate: Date
    public var resultType: WeighingResultType
    public var timesMilked: Int
    public var absenceReason: AbsenceReason?
    public var milkYield: Double
    public var fatPct: Double
    public var proteinPct: Double
    public var lactosePct: Double
    public var cellCount: Int

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        recordingDate = try Field(location: 3, length: 6).extractValue(from: content)
        resultType = try Field(location: 10, length: 1).extractValue(from: content)
        timesMilked = try Field(location: 12, length: 1).extractValue(from: content)
        absenceReason = try Field(location: 14, length: 1).extractValue(from: content)
        milkYield = try Field(location: 16, length: 4, divisor: 10).extractValue(from: content)
        fatPct = try Field(location: 21, length: 4, divisor: 100).extractValue(from: content)
        proteinPct = try Field(location: 26, length: 4, divisor: 100).extractValue(from: content)
        lactosePct = try Field(location: 31, length: 4, divisor: 100).extractValue(from: content)
        cellCount = try Field(location: 46, length: 4).extractValue(from: content)
    }
}

public struct ServiceRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.eventService]
    }

    public var eventDate: Date
    public var isAuthentic: Bool
    public var sireBreed: Int
    public var sireIdentity: String
    public var sireIdentityAuthenticity: ItemAuthenticity
    public var pregnancyStatus: PregnancyStatus

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        eventDate = try Field(location: 3, length: 6).extractValue(from: content)
        isAuthentic = try Field(location: 10, length: 1).extractValue(from: content)
        sireBreed = try Field(location: 15, length: 2).extractValue(from: content)
        sireIdentity = try Field(location: 18, length: 12).extractValue(from: content)
        sireIdentityAuthenticity = try Field(location: 31, length: 1).extractValue(from: content)
        pregnancyStatus = try Field(location: 37, length: 1).extractValue(from: content)
    }
}

public struct ActualCalvingRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.eventActualCalving]
    }

    public var eventDate: Date
    public var eventAuthenticity: ItemAuthenticity
    public var calf1Breed: Int
    public var calf1Identity: String
    public var calf1IdentityType: IdentityType
    public var calf1IdentityAuthenticity: ItemAuthenticity
    public var calf1Sex: Sex?
    public var calf2Breed: Int
    public var calf2Identity: String
    public var calf2IdentityType: IdentityType
    public var calf2IdentityAuthenticity: ItemAuthenticity
    public var calf2Sex: Sex?

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        eventDate = try Field(location: 3, length: 6).extractValue(from: content)
        eventAuthenticity = try Field(location: 10, length: 1).extractValue(from: content)
        calf1Breed = try Field(location: 15, length: 2).extractValue(from: content)
        calf1Identity = try Field(location: 18, length: 12).extractValue(from: content)
        calf1IdentityType = try Field(location: 31, length: 1).extractValue(from: content)
        calf1IdentityAuthenticity = try Field(location: 33, length: 1).extractValue(from: content)
        calf1Sex = try Field(location: 35, length: 1).extractValue(from: content)
        calf2Breed = try Field(location: 37, length: 2).extractValue(from: content)
        calf2Identity = try Field(location: 40, length: 12).extractValue(from: content)
        calf2IdentityType = try Field(location: 53, length: 1).extractValue(from: content)
        calf2IdentityAuthenticity = try Field(location: 55, length: 1).extractValue(from: content)
        calf2Sex = try Field(location: 57, length: 1).extractValue(from: content)
    }
}

public struct ActualThirdCalfRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.eventActualCalving]
    }

    public var calfBreed: Int
    public var calfIdentity: String
    public var calfIdentityType: IdentityType
    public var calfIdentityAuthenticity: ItemAuthenticity
    public var calfSex: Sex?

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        calfBreed = try Field(location: 3, length: 2).extractValue(from: content)
        calfIdentity = try Field(location: 6, length: 12).extractValue(from: content)
        calfIdentityType = try Field(location: 19, length: 1).extractValue(from: content)
        calfIdentityAuthenticity = try Field(location: 21, length: 1).extractValue(from: content)
        calfSex = try Field(location: 23, length: 1).extractValue(from: content)
    }
}

public struct AssumedCalvingRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.eventAssumedCalving]
    }

    public var eventDate: Date

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        eventDate = try Field(location: 3, length: 6).extractValue(from: content)
    }
}

public struct OtherEventRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.eventNoSample, .eventAssumed1x,      .event1x,     .eventAssumedDry,
                .eventDry,      .eventSuckling,       .eventAbsent, .eventBarren,
                .eventAbort,    .eventSick,           .eventLame,   .eventMastitis,
                .eventDead,     .eventSoldInPrevHerd, .eventSold]
    }

    public var eventDate: Date
    public var eventAuthenticity: ItemAuthenticity

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        eventDate = try Field(location: 3, length: 6).extractValue(from: content)
        eventAuthenticity = try Field(location: 10, length: 1).extractValue(from: content)
    }
}

public struct LactationDetailsRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var checksum: Int
    public var checksumIsValid: Bool
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.currentLactationTotals]
    }

    public var totalDays: Int
    public var totalMilk: Double
    public var totalFat: Double
    public var totalProtein: Double
    public var totalLactose: Double
    public var fatPct: Double
    public var proteinPct: Double
    public var lactosePct: Double
    public var totalValue: Int
    public var averagePencePerLitre: Double
    public var seasonality: Seasonality
    public var averageCellCount: Int

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        checksum = try Field.checksumField.extractValue(from: content)
        checksumIsValid = Self.validateRecordStringChecksum(content)
        
        totalDays = try Field(location: 3, length: 4, divisor: 10).extractValue(from: content)
        totalMilk = try Field(location: 8, length: 6, divisor: 10).extractValue(from: content)
        totalFat = try Field(location: 15, length: 6, divisor: 100).extractValue(from: content)
        totalProtein = try Field(location: 22, length: 6, divisor: 100).extractValue(from: content)
        totalLactose = try Field(location: 29, length: 6, divisor: 100).extractValue(from: content)
        fatPct = try Field(location: 36, length: 4, divisor: 100).extractValue(from: content)
        proteinPct = try Field(location: 41, length: 4, divisor: 100).extractValue(from: content)
        lactosePct = try Field(location: 46, length: 4, divisor: 100).extractValue(from: content)
        totalValue = try Field(location: 51, length: 6).extractValue(from: content)
        averagePencePerLitre = try Field(location: 58, length: 4, divisor: 100).extractValue(from: content)
        seasonality = try Field(location: 63, length: 1).extractValue(from: content)
        averageCellCount = try Field(location: 65, length: 4).extractValue(from: content)
    }
}
