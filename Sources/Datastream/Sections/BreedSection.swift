//
//  BreedSection.swift
//  
//
//  Created by Ben Barnett on 15/11/2021.
//

import Foundation

/// A breed as used by the NMR recording system
public final class Breed {
    
    /// Numeric breed code
    public var code: Int
    
    /// A breed that is similar to this one for the purpose of
    /// lactation curve calculations
    public weak var equivalent: Breed?
    
    /// Full name of this breed
    public var name: String
    
    /// A two-character abbreviation
    public var abbreviation: String
    
    /// Gestation period in days
    ///
    /// For first calvers, reduce this value by two days
    public var gestationPeriod: Int
    
    /// The type of animal
    public var type: BreedType
    
    /// Whether this uses a non-UK herd book
    ///
    /// Not for use for calves born in mainland UK
    public var isImported: Bool
    
    /// Minimum recordable milk yield
    ///
    /// The minimum *actual* yield is of course zero. However figures
    /// below the value of `minDailyYield` are not considered
    /// recordable.
    public var minDailyYield: Double
    
    /// Maximum acceptable value for recording
    public var maxDailyYield: Double
    
    /// The amount of milk below which a recording is queried
    public var lowMilkQuery: Double
    
    /// The amount of milk above which a recording is queried
    public var highMilkQuery: Double
    
    /// The percentage of fat below which a recording is queried
    public var minFatPct: Double
    
    /// The percentage of fat above which a recording is queried
    public var maxFatPct: Double
    
    /// The weight of fat below which a recording is queried
    public var lowFatQuery: Double
    
    /// The weight of fat above which a recording is queried
    public var highFatQuery: Double
    
    /// The percentage of protein below which a recording is queried
    public var minProteinPct: Double
    
    /// The percentage of protein above which a recording is queried
    public var maxProteinPct: Double
    
    /// The weight of protein below which a recording is queried
    public var lowProteinQuery: Double
    
    /// The weight of protein above which a recording is queried
    public var highProteinQuery: Double
    
    /// The percentage of lactose below which a recording is queried
    public var minLactosePct: Double
    
    /// The percentage of lactose above which a recording is queried
    public var maxLactosePct: Double
    
    /// The weight of lactose below which a recording is queried
    public var lowLactoseQuery: Double
    
    /// The weight of lactose above which a recording is queried
    public var highLactoseQuery: Double
    
    /// The value of milk yield above which a 305d lactation is queried
    public var high305dYieldQuery: Int
    
    /// The value of milk yield above which a natural lactation is queried
    public var highNaturalYieldQuery: Int
    
    /// The maximum acceptable value for a 305d lactation milk yield
    public var max305dYield: Int
    
    /// The maximum acceptable value for a natural lactation milk yield
    public var maxNaturalYield: Int
    
    public init(code: Int,
                equivalent: Breed?,
                name: String,
                abbreviation: String,
                gestationPeriod: Int,
                type: BreedType,
                isImported: Bool,
                minDailyYield: Double,
                maxDailyYield: Double,
                lowMilkQuery: Double,
                highMilkQuery: Double,
                minFatPct: Double,
                maxFatPct: Double,
                lowFatQuery: Double,
                highFatQuery: Double,
                minProteinPct: Double,
                maxProteinPct: Double,
                lowProteinQuery: Double,
                highProteinQuery: Double,
                minLactosePct: Double,
                maxLactosePct: Double,
                lowLactoseQuery: Double,
                highLactoseQuery: Double,
                high305dYieldQuery: Int,
                highNaturalYieldQuery: Int,
                max305dYield: Int,
                maxNaturalYield: Int) {
        self.code = code
        self.equivalent = equivalent
        self.name = name
        self.abbreviation = abbreviation
        self.gestationPeriod = gestationPeriod
        self.type = type
        self.isImported = isImported
        self.minDailyYield = minDailyYield
        self.maxDailyYield = maxDailyYield
        self.lowMilkQuery = lowMilkQuery
        self.highMilkQuery = highMilkQuery
        self.minFatPct = minFatPct
        self.maxFatPct = maxFatPct
        self.lowFatQuery = lowFatQuery
        self.highFatQuery = highFatQuery
        self.minProteinPct = minProteinPct
        self.maxProteinPct = maxProteinPct
        self.lowProteinQuery = lowProteinQuery
        self.highProteinQuery = highProteinQuery
        self.minLactosePct = minLactosePct
        self.maxLactosePct = maxLactosePct
        self.lowLactoseQuery = lowLactoseQuery
        self.highLactoseQuery = highLactoseQuery
        self.high305dYieldQuery = high305dYieldQuery
        self.highNaturalYieldQuery = highNaturalYieldQuery
        self.max305dYield = max305dYield
        self.maxNaturalYield = maxNaturalYield
    }
}


/// The typical purpose of a breed
public enum BreedType {
    
    /// A milking breed
    case dairy
    
    /// An breed grown for meat
    case beef
    
    /// An breed used for both milk and meat
    case dualPurpose
    
    /// Unspecified
    case unspecified
}
