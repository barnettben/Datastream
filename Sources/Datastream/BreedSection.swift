//
//  BreedSection.swift
//  
//
//  Created by Ben Barnett on 15/11/2021.
//

import Foundation

/// Represents a breed as used by the NMR recording system
public struct Breed {
    
    /// Numeric breed code
    public var code: Int
    
    /// A breed that is similar to this one for the purpose of
    /// lactation curve calculations
    public var equivalent: Int
    
    /// Full name of this breed
    public var name: String
    
    /// A two-character abbreviation
    public var abbreviation: String
    
    /// Gestation period in days
    public var gestationPeriod: Int
    
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
}
