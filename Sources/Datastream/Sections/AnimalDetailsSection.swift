//
//  File.swift
//  
//
//  Created by Ben Barnett on 04/11/2021.
//

import Foundation

/// An animal which is recorded within the milking herd
public struct Animal {
    
    /// NMR herd number
    public var nmrHerdNumber: String
    
    /// Whether the animal is present or dead/sold
    public var isInHerd: Bool
    
    /// Line number in the herd
    ///
    /// Line numbers are specified to be numeric in the file format.
    /// However on-farm they may not be, so here we choose to
    /// deviate from the spec a little, and handle as a `String`.
    public var lineNumber: String
    
    /// The breed of the animal
    public var breed: Breed
    
    /// Earmark or herdbook number
    public var identity: String
    
    /// The type of ID used in ``identity``
    public var identityType: IdentityType
    
    /// The pedigree status of the animal
    public var pedigreeStatus: PedigreeStatus
    
    /// Indicates whether the identity is genuine
    public var hbnAuthenticity: ItemAuthenticity
    
    /// Indicates whether the identity is genuine
    public var identityAuthenticity: ItemAuthenticity
    
    /// An alternative breed for this animal
    public var alternativeBreed: Breed
    
    /// An alternative identity number
    public var alternativeID: String
    
    /// The birth date for the animal
    public var birthDate: Date
    
    /// Whether the animal has calved at any point
    public var isYoungstock: Bool
    
    /// The date the animal was first recorded in the herd
    public var herdEntryDate: Date
    
    /// The date the animal left the herd, if applicable
    public var herdExitDate: Date?
    
    /// The reason the animal left the herd
    public var leavingReason: LeavingReason
    
    /// Date of change of pedigree class
    public var classChangeDate: Date?
    
    /// The animal's short name
    public var shortName: String
    
    /// The animal's long name
    public var longName: String
    
    /// Details of the animal's mother
    public var dam: AnimalParent
    
    /// Details of the animal's father
    public var sire: AnimalParent
    
    /// PTA evaluations for the animal
    public var evaluations: [GeneticEvaluation]
}

// MARK: - Associated types

/// The type of identifier used for an animal
public enum IdentityType: Int {
    
    /// This animal has no ID
    case noID = 0
    
    /// ID is a pedigree herdbook number
    case pedigreeHBN = 1
    
    /// ID is an eartag number
    case earmark = 2
    
    /// ID is an AI number
    /// - Note: This case is only appropriate for sires
    case aiNumber = 3
    
    /// ID is a line number (management tag or similar)
    case lineNumber = 4
    
    /// ID type is present, but invalid
    case invalid = 5
    
    /// ID is missing
    ///
    /// This is somehow distinct from `.noID`
    case missing = 6
    
    /// ID is 'BEEF'
    /// - Note: `.beef` is only appropriate for calves
    case beef = 7
}

public enum PedigreeStatus {
    
    /// Pedigree status is not known
    case unknown
    
    /// Animal is pedigree registered
    case pedigree
    
    /// Animal is not pedigree registered
    case nonPedigree
    
    ///
    case hybrid
    
    /// Animal is in the process of becoming registered
    ///
    /// Valid stages are characters `A` through `D`
    case gradingUp(stage: Character)
    
    /// Animal is not a full pedigree, but is recorded in
    /// a supplementary register.
    ///
    /// Valid sources are characters `J` through `T`
    case supplementaryRegister(source: Character)
}
extension PedigreeStatus: RawRepresentable {
    public init?(rawValue: Character) {
        switch rawValue {
        case "0":
            self = .unknown
        case "1":
            self = .pedigree
        case "2":
            self = .nonPedigree
        case "5":
            self = .hybrid
        case let value where "ABCD".contains(rawValue):
            self = .gradingUp(stage: value)
        case let value where "JKLMNOPQRST".contains(rawValue):
            self = .supplementaryRegister(source: value)
        default:
            fatalError("Invalid option \(rawValue) provided to \(#function)")
        }
    }
    
    public var rawValue: Character {
        switch self {
        case .unknown:
            return "0"
        case .pedigree:
            return "1"
        case .nonPedigree:
            return "2"
        case .hybrid:
            return "5"
        case .gradingUp(let stage):
            return stage
        case .supplementaryRegister(let source):
            return source
        }
    }
}

/// Whether a given field is 'authentic'.
///
/// I'm not certain what 'authentic' means here. Likely whether or not
/// a given identity or event is registered with an appropriate authority.
public enum ItemAuthenticity: Int {
    case authentic = 0
    case nonAuthentic = 1
    case computerGenerated = 3
}

/// Why an animal left the herd
public enum LeavingReason: Int {
    /// The animal is still in the herd
    case inHerd = 0
    
    /// The animal died
    case died = 1
    
    /// The animal was sold
    case sold = 2
    
    /// The animal ceased recording, but may still be
    /// alive and physically present.
    case ceasedRecording = 4
}

/// A parent of a milking animal
///
/// This may refer to either dam or sire.
/// - Note: `.pedigreeStatus` and `.identityAuthenticicity`
/// are only use for dams and will be `nil` for sires.
public struct AnimalParent {
    
    /// The identity of this parent
    public var identity: String
    
    /// The type of ID used in ``identity``
    public var identityType: IdentityType
    
    /// The breed of this parent
    public var breed: Breed
    
    /// The pedigree status of this parent
    ///
    /// Available options are the same as those used for
    /// the pedigree status used in ``Animal``
    /// - Important: This property is not used for sires and will be `nil`
    public var pedigreeStatus: PedigreeStatus?
    
    /// Indicates the authenticity of this parent's identity
    ///
    /// Available options are the same as those used for
    /// the id authenticity used in ``Animal``
    /// - Important: This property is not used for sires and will be `nil`
    public var identityAuthenticity: ItemAuthenticity?
}

/// Represents how well a given animal can pass on its useful genetic features to offspring
///
/// This is described as Predicted Transmitting Ability (PTA). PTA is the predicted difference of a
/// given animal's offspring compared to the average of a population.
///
/// The population used is typically within a breed - for example comparing a specific Friesian cow
/// against the average of all Friesian cows.
///
/// Different PTAs have their own units which are described for each property below
public struct GeneticEvaluation {
    
    /// The group (breed) to which the genetic evaluation belongs
    public var evaluationGroup: EvaluationGroup
    
    /// The source of the PTA results
    public var evaluationSource: EvaluationSource
    
    /// The date of the evaluation
    ///
    /// This defaults to 1997-07-01.
    public var evaluationDate: Date
    
    /// PTA weight of milk per lactation in kg
    public var ptaMilkKG: Int
    
    /// PTA weight of fat per lactation in kg
    public var ptaFatKG: Double
    
    /// PTA weight of protein per lactation in kg
    public var ptaProteinKG: Double
    
    /// PTA percentage points of butterfat
    public var ptaFatPct: Double
    
    /// PTA percentage points of protein
    public var ptaProteinPct: Double
    
    /// How reliable the PTA values of this evaluation are
    ///
    /// Range is 0-99, with higher values being more reliable
    public var reliability: Int
}

/// A population of animals, typically a breed, whose average
/// can be used to compare individual cows against
public enum EvaluationGroup: Int {
    case none = 0
    case holsteinFriesian = 1
    case shorthorn = 2
    case ayrshire = 3
    case jersey = 4
    case guernsey = 5
    case isleOfJersey = 6
    case isleOfGuernsey = 7
}

/// A population of animals, typically a breed, whose average
/// can be used to compare individual cows against
public enum EvaluationSource: Int {
    // These first eight are the same as EvaluationGroup
    case none = 0
    case holsteinFriesian = 1
    case shorthorn = 2
    case ayrshire = 3
    case jersey = 4
    case guernsey = 5
    case isleOfJersey = 6
    case isleOfGuernsey = 7
    
    case estimated = 97
    case indirectForeign = 98
    case directForeign = 99
}
