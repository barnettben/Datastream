//
//  DamSection.swift
//  
//
//  Created by Ben Barnett on 14/11/2021.
//

import Foundation

/// A cow, not in the herd, with only daughters in this herd
///
/// A `DeadDam` may never have existed in this herd or may have been dead
/// for many years but still has daughters in the herd. This allows to to refer to
/// an animal without storing the level of detail contained in ``Animal``.
public struct DeadDam {
    
    /// The dam's identity mark
    public var identity: String
    
    /// The type of ID used in ``identity``
    public var identityType: IdentityType
    
    /// Whether ``identity`` is authentic
    public var identityAuthenticity: ItemAuthenticity
    
    /// The dam's breed
    public var breedCode: Int
    
    /// The dams's pedigree status
    public var pedigreeStatus: PedigreeStatus
    
    /// The dam's long name
    public var name: String
    
    /// PTA evaluations for this dam
    ///
    /// Typically there will be only one evaluation, but between zero
    /// and seven may be included
    public var evaluations: [GeneticEvaluation]
}
