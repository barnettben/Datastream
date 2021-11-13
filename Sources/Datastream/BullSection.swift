//
//  File.swift
//  
//
//  Created by Ben Barnett on 13/11/2021.
//

import Foundation

/// Contains identity and PTA information for a sire
public struct BullDetails {
    
    /// The sire's breed code
    public var breed: Int
    
    /// The sire's identity number
    public var identity: String
    
    /// The sire's long name
    public var longName: String
    
    /// The sire's abbreviated name
    public var shortName: String
    
    /// PTA evaluations for this sire
    ///
    /// Typically there will be only one evaluation, but up to
    /// seven may be included
    public var evaluations: [GeneticEvaluation]
}
