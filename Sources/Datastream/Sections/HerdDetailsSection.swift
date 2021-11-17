//
//  HerdDetails.swift
//  
//
//  Created by Ben Barnett on 19/10/2021.
//

import Foundation

/// Information about the herd being recorded
public struct HerdDetails {
    public var nationalHerdMark: String
    public var predominantBreed: Int
    public var herdPrefix: String
    public var enrolDate: Date
    
    public var address: [String]
    public var county: String
    public var postcode: String
    
    public var nmrInformation: NMRInformation
}

/// NMR registration and service details for a farm
public struct NMRInformation {
    public var nmrCounty: Int
    public var nmrOffice: Int
    public var recordingScheme: RecordingScheme
    public var weighingSequence: Int
    public var lastWeighNumber: Int
    public var serviceType: ServiceType
    public var isProgenyTesting: Bool
    public var isLifetimeYieldMember: Bool
    public var cowCardCycle: CowCardPrinting
    public var calfCropListCycle: Int
    public var isHerdwatch: Bool
    public var cellCountMembership: CellCountMembership
    public var internalHerdRecords: [SomeRecord]
}

/// An overview of a single milk recording
public struct HerdRecording {
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
    public var bulkYield: Int
    public var bulkFatPct: Double
    public var bulkProteinPct: Double
    public var bulkLactosePct: Double
    public var herdProductionBase: Int
    public var bulkCellCount: Int
}
