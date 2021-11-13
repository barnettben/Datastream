//
//  File.swift
//  
//
//  Created by Ben Barnett on 07/11/2021.
//

import Foundation

/// A model containing production-related information for a given animal's current lactation
///
/// It may contain details of milk recordings, service, calving and other events details as
/// well as production data for the current lactation.
public struct AnimalStatement {
    
    /// The management line number of this animal
    public var lineNumber: String
    
    /// Whether the animal is present or dead/sold
    ///
    /// 0 = Present, 1-9 = Dead/sold
    public var aliveFlag: Int
    
    /// Whether this animal is a cow or youngstock
    public var isYoungstock: Bool
    
    /// The breed code of this animal
    public var breedCode: Int
    
    /// The animal's lactation number.
    ///
    /// This may fall in one of two ranges:
    /// - `1 ... 25` for confirmed lactation numbers
    /// - `81 ... 99` for estimated lactation numbers
    ///
    /// Estimated numbers occur when an animal was not recorded during its
    /// milking life.
    ///
    /// If the value of this property falls within the estimated range, you can check
    /// ``estimatedLactationNumber`` for a corrected value.
    public var lactationNumber: Int
    
    /// Estimated lactation number
    ///
    /// If ``lactationNumber`` is in the range `81` to `99` then this field
    /// will contain an estimated lactation number. Otherwise it will be `0`.
    public var estimatedLactationNumber: Int
    
    /// The management group for this animal
    /// May be in the range 0-99
    public var managementGroup: Int
    
    /// Whether (and how) this lactation has ended
    public var lactationStage: LactationStage
    
    /// The date of the last calving
    public var previousCalvingDate: Date?
    
    /// The details of the sire to the calf that began the current lactation
    public var sireDetails: SireDetails
    
    /// Number of days between going dry in the previous lactation
    /// and the most recent calving date
    public var dryDays: Int
    
    /// Milk weighings for the current lactation
    public var weighings: [WeighingEvent]
    
    /// Service details for the current lactation
    public var services: [ServiceEvent]
    
    /// Calf and calving details for the current lactation
    public var calvings: [CalvingEvent]
    
    /// Any other events the current lactation
    public var otherEvents: [OtherEvent]
    
    /// Production details for the current lactation
    public var lactationDetails: LactationDetails
}

/// A milk recording event
///
/// Contains details of milk quantity and qualities
public struct WeighingEvent {
    
    /// The weighing date
    public var recordingDate: Date
    
    /// Whether this weighing event is measured or estimated
    public var resultType: WeighingResultType
    
    /// Number of times milked per day
    ///
    /// May be 1, 2 or 3
    public var timesMilked: Int
    
    /// The reason for a lack of weighing data
    public var absenceReason: AbsenceReason?
    
    /// The milk yield in KG
    public var milkYield: Double
    
    /// The fat percentage at this weighing
    public var fatPct: Double
    
    /// The protein percentage at this weighing
    public var proteinPct: Double
    
    /// The lactose percentage at this weighing
    public var lactosePct: Double
    
    /// The somatic cell count at this recording
    ///
    /// Units: cells x10^3 /ml
    public var cellCount: Int
}

/// Represents an insemination event
public struct ServiceEvent {
    
    /// The event date
    public var eventDate: Date
    
    /// Whether this event is authentic
    public var isAuthentic: Bool
    
    /// The service sire breed
    public var sireBreed: Int
    
    /// The service sire identity
    public var sireIdentity: String
    
    /// Whether the service sire ID is authentic
    public var sireIdentityAuthenticity: ItemAuthenticity
    
    /// Whether this service resulted in a pregnancy
    public var pregnancyStatus: PregnancyStatus
}


/// Represents a calving event.
///
/// In the event of twins or triplets, there may be multiple ``CalvingEvent``
/// items for a single cow.
///
/// - Important: If a calving is assumed (ie. ``isAssumed`` is `true`), then only ``eventDate``
/// will have useful information. All other information will be invalid. Assumed calvings are
/// created when a cow has come into milk but no calving has been recorded. In this case
/// an assumed calving will be created.
public struct CalvingEvent {
    
    /// The date this calving occurred
    public var eventDate: Date
    
    /// Whether this event is authentic
    public var eventAuthenticity: ItemAuthenticity
    
    /// Whether this event is assumed or recorded
    public var isAssumed: Bool
    
    /// The breed of the calf born
    public var calfBreed: Int
    
    /// The identity of the calf born
    public var calfIdentity: String
    
    /// The type of identity in ``calfIdentity``
    public var calfIdentityType: IdentityType
    
    /// Whether this identity is authentic
    public var calfIdentityAuthenticity: ItemAuthenticity
    
    /// The sex of the calf born
    public var calfSex: Sex
}

/// Events other than milk recording, services and calvings
///
/// Only date, authenticity and event types are stored.
/// Event types are shown by the ``RecordDescriptor`` and may only
/// include items from `S8` to `SM`.
public struct OtherEvent {
    
    /// The date of this event
    public var eventDate: Date
    
    /// Whether this event is authentic
    public var eventAuthenticity: ItemAuthenticity
    
    /// The type of event recorded.
    ///
    /// This may include items in the range `S8` to `SM`
    public var eventType: RecordDescriptor
}

public struct LactationDetails {
    
    /// Days since last calving
    public var totalDays: Int
    
    /// Total weight of milk this lactation
    public var totalMilk: Double
    
    /// Total weight of fat this lactation
    public var totalFat: Double
    
    /// Total weight of protein this lactation
    public var totalProtein: Double
    
    /// Total weight of lactose this lactation
    public var totalLactose: Double
    
    /// Fat percentage this lactation
    public var fatPct: Double
    
    /// Protein percentage this lactation
    public var proteinPct: Double
    
    /// Lactose percentage this lactation
    public var lactosePct: Double
    
    /// Total monetary value of milk produced
    ///
    /// Unit is £0.1?
    public var totalValue: Int
    
    /// Average price of milk sold in pence per litre
    public var averagePencePerLitre: Double
    
    /// Whether seasonality adjustments are applied
    public var seasonality: Seasonality
    
    /// Lactation average cell count
    ///
    /// This is a geometric mean. It is calculated by:
    /// 1. Summing the log value of each non-zero cell count in the current lactation
    /// 2. Dividing by the number of contributors
    /// 3. Antilogging the result
    public var averageCellCount: Int
}

/// Details of a service sire
public struct SireDetails {
    /// The breed code of this sire
    public var sireBreed: Int
    
    /// The identity of this sire
    public var sireIdentity: String
    
    /// The type of identity used in ``sireIdentity``
    public var sireIdentityType: IdentityType
    
    /// Whether the identity of this sire is authentic
    public var sireIdentityAuthenticity: ItemAuthenticity
}


/// Whether a lactation is complete
public enum LactationStage: Int {
    
    /// Lactation is ongoing
    case ongoing = 0
    
    /// Lactation is assumed to have ended
    case assumedEnded = 1
    
    /// Lactation period confirmed to have ended
    case ended = 2
    
    /// Lactation period assumed to have naturally ended
    case assumedNaturalEnd = 3
    
    /// Lactation period confirmed to have naturally ended
    case definiteNaturalEnd = 4
}

/// The type of weighing result
public enum WeighingResultType: Int {
    
    /// A normal recording
    case normal = 0
    
    /// Fat/protein/lactose values are estimated
    case solidsEstimated = 1
    
    /// All values are estimated due to the cows absence
    case fullEstimateAbsent = 2
    
    /// All values are estimated as the cow was not recorded
    /// due to illness
    case fullEstimateSick = 3
}

/// The reason for a lack of weighing data
public enum AbsenceReason: Int {
    
    /// No sample was taken
    case noSample = 0
    
    /// The sample was lost
    case spilt = 1
    
    /// The milk spoiled before being tested
    case sour = 2
    
    /// The sample was contaminated
    case dirty = 3
    
    /// Some other abnormality of the milk prevented testing
    case abnormal = 4
}

/// The state of a potential pregnancy
public enum PregnancyStatus: Int {
    
    /// A pregnancy has not been checked or is not confirmed either way
    case unknown = 0
    
    /// Confirmed not pregnant
    case notPregnant = 1
    
    /// Confirmed pregnant
    case pregnant = 2
}

/// The sex of an animal
///
/// The specification defines three sexes: male (`B`), female (`H`) and dead (`D`).
/// In real-world files there are also `M` and `F` which we can assume to be male/female.
///
/// This enum does not distinguish between `M`/`B` or `F`/`H` and maps them to
/// male or female respectively. Internally it uses `B`/`H`/`D` as this is what the
/// specification describes.
///
/// - Important: Real-world use of this enum differs from the specification. See discussion above.
public enum Sex: Character {
    
    /// A female animal
    case female = "H"
    
    /// A male animal
    case male   = "B"
    
    /// A dead animal
    case dead   = "D"
    
    public init?(rawValue: Character) {
        switch rawValue {
        case "H", "F":
            self = .female
        case "B", "M":
            self = .male
        case "D":
            self = .dead
        default:
            return nil
        }
    }
}

public enum Seasonality: Character {
    case noSeasonality = "G"
    case seasonality = "N"
    case comparative = "C"
}
