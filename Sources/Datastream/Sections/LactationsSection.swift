//
//  LactationsSection.swift
//  
//
//  Created by Ben Barnett on 12/11/2021.
//

import Foundation

/// Details of a completed lactation for an animal currently in the herd
public struct Lactation {
    
    /// The management line number of this animal
    public var lineNumber: String
    
    /// Whether the animal is present or dead/sold
    public var isInHerd: Bool
    
    /// The animal's lactation number.
    public var lactationNumber: Int
    
    /// The animal's  estimated lactation number.
    ///
    /// See  `AnimalStatement`.``AnimalStatement/estimatedLactationNumber`` for more details
    public var estimatedLactationNumber: Int
    
    /// This animal's breed
    public var breed: Breed
    
    /// The number of male calves born this lactation
    public var totalMaleCalves: Int
    
    /// The number of female calves born this lactation
    public var totalFemaleCalves: Int
    
    /// The number of dead calves born this lactation
    public var totalDeadCalves: Int
    
    /// The number of days between the natural end date of the previous
    /// lactation and the start of this one
    public var numberOfDryDays: Int
    
    /// The number of services in this lactation
    public var numberOfServices: Int
    
    /// The number of times this animal missed recording
    public var missedRecordings: Int
    
    /// The effect of seasonality payments on the financial value
    /// of this lactation
    public var seasonalityAdjustment: Int
    
    /// The financial value of milk produced this lactation
    public var financialValue: Int
    
    /// The production index of this lactation
    public var productionIndex: Int
    
    /// The herd production base
    ///
    /// ``productionIndex`` is calculated against this base figure
    public var productionBase: Double
    
    /// The number of lameness events recorded
    public var numberOfTimesLame: Int
    
    /// The number of mastitis events recorded
    public var numberOfTimesMastitis: Int
    
    /// The number of sickness events recorded
    public var numberOfTimesSick: Int
    
    /// The number of days between the start of the previous lactation
    /// and the start of this lactation
    public var calvingInterval: Int
    
    /// The animal's age in months at the start of this lactation
    public var ageAtCalving: Int
    
    /// The date this lactation started
    public var calvingDate: Date
    
    /// Whether the calving date is authentic
    public var calvingDateAuthenticity: ItemAuthenticity
    
    /// The details of the sire to calves born this lactation
    public var sireDetails: SireDetails
    
    /// Calves born to this lactation
    ///
    /// It is possible to have no calves recorded, in which case this array
    /// will be empty.
    public var calves: [CalvingEvent]
    
    /// 305-day lactation production details
    public var production305: LactationProduction
    
    /// Natural lactation production details
    public var productionNatural: LactationProduction?
}

public struct LactationProduction {
    
    /// Whether this lactation qualifies for publication
    public var isQualifiedForPublication: Bool
    
    /// Whether the total figures this lactation are authentic
    public var totalAuthenticity: ItemAuthenticity
    
    /// The weight of milk in kg this lactation
    public var milkYield: Double
    
    /// The weight of fat in kg this lactation
    public var fatYield: Double
    
    /// The weight of protein in kg this lactation
    public var proteinYield: Double
    
    /// The weight of lactose in kg this lactation
    public var lactoseYield: Double
    
    /// The duration of this lactation in days
    public var totalDays: Int
    
    /// The number of days this animal was milked three times a day
    public var total3xDays: Int
    
    /// The number of days into this lactation when 3x milking began
    public var startOf3x: Int
    
    /// The date this lactation ended
    public var lactationEndDate: Date
    
    /// The reason this lactation ended
    public var lactationEndReason: EndReason
    
    /// The number of milk recordings completed in this lactation
    public var numberOfRecordings: Int
    
    /// The geometric average cell count
    ///
    /// See ``LactationDetails/averageCellCount`` for calculation details
    public var averageCellCount: Int
    
    /// The number of cell count tests that exceeded 200k cells/ml
    public var cellsOver200: Int
}

/// The reason a lactation was ended
public enum EndReason: Int {
    
    /// The animal died
    case dead = 1
    
    /// The animal was sold
    case sold = 2
    
    /// The animal was dried off
    case dry = 3
    
    /// The animal moved to once-a-day milking
    case onceADay = 4
    
    /// Low production?
    ///
    /// This case is not explained in the specification
    case lp = 5
    
    /// The animal calved
    case calved = 6
    
    /// The animal ceased to be recorded
    case ceasedRecording = 7
    
    /// The animal began suckling a calf
    case suckled = 8
}
