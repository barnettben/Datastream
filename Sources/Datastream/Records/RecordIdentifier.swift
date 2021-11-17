//
//  RecordIdentifier.swift
//  
//
//  Created by Ben Barnett on 17/10/2021.
//

import Foundation

/// Represents the type of a given record
///
/// Record identifiers are two-character strings. The first character is a letter denoting
/// the section to which the record belongs (see ``RecordSection``). The second
/// character is a number or letter identifying the type within a section.
///
/// - Note: The `H` and `W` section actually consists of two subsections within one letter code.
/// The `H` section contains both farm/NMR subscription details and a list of milk recordings.
/// The `W` section contains both the weighing calendar and breed file. These are reference items and
/// are not farm-specific.
public enum RecordIdentifier: String {
    
    // MARK: Herd details
    // Herd fixed records
    case nmrDetails = "H1"
    case address1 = "H2"
    case address2 = "H3"
    case address3 = "H4"
    case address4 = "H5"
    case address5 = "H6"
    case serviceIndicators = "H7"
    case serviceIndicatorsContinued = "H8"
    case header9 = "H9" // NMR private use
    case headerA = "HA" // NMR private use
    case headerB = "HB" // NMR private use
    case headerC = "HC" // NMR private use
    
    // Herd recording records
    case recordingPart1 = "HD"
    case recordingPart2 = "HE"
    
    // MARK: Cow details
    case animalIdentity     = "C1"
    case animalOtherDetails = "C2"
    case animalName         = "C3"
    case animalSireDam      = "C4"
    case animalPTA          = "C5"
    case animalPTA2         = "C6"
    case animalPTA3         = "C7"
    case animalPTA4         = "C8"
    
    // MARK: Statement section
    case statementSectionLeader = "S0"
    case cowIDRecord            = "S1"
    case statementNMRUse        = "S2" // NMR private use
    case currentLactationTotals = "SX"
    case statementMMBUse        = "SZ" // MMB private use
    
    // Events
    case eventWeighing       = "S3"
    case eventService        = "S4"
    case eventActualCalving  = "S5"
    case eventCalving3rdCalf = "S6"
    case eventAssumedCalving = "S7"
    case eventNoSample       = "S8"
    case eventAssumed1x      = "S9"
    case event1x             = "SA"
    case eventAssumedDry     = "SB"
    case eventDry            = "SC"
    case eventSuckling       = "SD"
    case eventAbsent         = "SE"
    case eventBarren         = "SF"
    case eventAbort          = "SG"
    case eventSick           = "SH"
    case eventLame           = "SI"
    case eventMastitis       = "SJ"
    case eventDead           = "SK"
    case eventSoldInPrevHerd = "SL"
    case eventSold           = "SM"
    
    // MARK: Completed lactation section
    case lactationSectionLeader         = "L0"
    case lactationFixedDetails          = "L1"
    case calvingDetails                 = "L2"
    case calvingPossibleExtraCalves     = "L3"
    case lactation305dTotals            = "L4"
    case lactationNaturalTotals         = "L5"
    
    // MARK: Sire details section
    case bullDetails = "B1"
    case bullPTA1    = "B2"
    case bullPTA2    = "B3"
    case bullPTA3    = "B4"
    case bullPTA4    = "B5"
    case bullPTA5    = "B6"
    case bullPTA6    = "B7"
    case bullPTA7    = "B8"
    
    // MARK: Dead dam section
    case deadDamDetails = "D1"
    case deadDamPTA1    = "D2"
    case deadDamPTA2    = "D3"
    case deadDamPTA3    = "D4"
    case deadDamPTA4    = "D5"
    case deadDamPTA5    = "D6"
    case deadDamPTA6    = "D7"
    case deadDamPTA7    = "D8"
    
    // MARK: Breed file & weighing calendar
    // Weighing calendar
    case weighCalendarLeader  = "W1"
    case weighCalendarQuarter = "W2"
    case weighCalendarTrailer = "W3"
    
    // Breed file
    case breedRecord1 = "W4"
    case breedRecord2 = "W5"
    case breedRecord3 = "W6"
}

extension RecordIdentifier: CaseIterable {}

extension RecordIdentifier {
    
    /// The file section to which a record identifier belongs
    public var section: RecordSection {
        let idPrefix = String(rawValue.first!)
        return RecordSection(rawValue: idPrefix)!
    }
    
    /// Whether this identifier represents an NMR internal use record
    ///
    /// The structure of private use records is not documented in the specification, though
    /// their existence is.
    public var isPrivateUse: Bool {
        return RecordIdentifier.privateRecordIdentifiers.contains(self)
    }
    
    /// Records types marked as being for internal use only
    public static var privateRecordIdentifiers: [RecordIdentifier] {
        return [.header9, .headerA, .headerB, .headerC, .statementNMRUse, .statementMMBUse]
    }
}

extension RecordIdentifier {
    /// Provides a data type for a struct which can represent the current record type
    internal var recordType: Record.Type {
        switch self {
        case .nmrDetails:
            return NMRDetails.self
        case .address1:
            return AddressRecord.self
        case .address2:
            return AddressRecord.self
        case .address3:
            return AddressRecord.self
        case .address4:
            return AddressRecord.self
        case .address5:
            return AddressRecord.self
        case .serviceIndicators:
            return ServiceIndicators.self
        case .serviceIndicatorsContinued:
            return ServiceIndicatorsContinued.self
        case .header9:
            return SomeRecord.self
        case .headerA:
            return SomeRecord.self
        case .headerB:
            return SomeRecord.self
        case .headerC:
            return SomeRecord.self
        case .recordingPart1:
            return RecordingPart1.self
        case .recordingPart2:
            return RecordingPart2.self
        case .animalIdentity:
            return AnimalIdentityRecord.self
        case .animalOtherDetails:
            return AnimalOtherDetailsRecord.self
        case .animalName:
            return AnimalNameRecord.self
        case .animalSireDam:
            return AnimalParentsRecord.self
        case .animalPTA:
            return PTARecord.self
        case .animalPTA2:
            return PTARecord.self
        case .animalPTA3:
            return PTARecord.self
        case .animalPTA4:
            return PTARecord.self
        case .statementSectionLeader:
            return NMRNumberRecord.self
        case .cowIDRecord:
            return CowIDRecord.self
        case .statementNMRUse:
            return SomeRecord.self
        case .currentLactationTotals:
            return LactationDetailsRecord.self
        case .statementMMBUse:
            return SomeRecord.self
        case .eventWeighing:
            return WeighingRecord.self
        case .eventService:
            return ServiceRecord.self
        case .eventActualCalving:
            return ActualCalvingRecord.self
        case .eventCalving3rdCalf:
            return ActualThirdCalfRecord.self
        case .eventAssumedCalving:
            return AssumedCalvingRecord.self
        case .eventNoSample:
            return OtherEventRecord.self
        case .eventAssumed1x:
            return OtherEventRecord.self
        case .event1x:
            return OtherEventRecord.self
        case .eventAssumedDry:
            return OtherEventRecord.self
        case .eventDry:
            return OtherEventRecord.self
        case .eventSuckling:
            return OtherEventRecord.self
        case .eventAbsent:
            return OtherEventRecord.self
        case .eventBarren:
            return OtherEventRecord.self
        case .eventAbort:
            return OtherEventRecord.self
        case .eventSick:
            return OtherEventRecord.self
        case .eventLame:
            return OtherEventRecord.self
        case .eventMastitis:
            return OtherEventRecord.self
        case .eventDead:
            return OtherEventRecord.self
        case .eventSoldInPrevHerd:
            return OtherEventRecord.self
        case .eventSold:
            return OtherEventRecord.self
        case .lactationSectionLeader:
            return NMRNumberRecord.self
        case .lactationFixedDetails:
            return CompletedLactationRecord.self
        case .calvingDetails:
            return CalvingDetailsRecord.self
        case .calvingPossibleExtraCalves:
            return CalvingExtraCalvesRecord.self
        case .lactation305dTotals:
            return LactationTotalsRecord.self
        case .lactationNaturalTotals:
            return LactationTotalsRecord.self
        case .bullDetails:
            return BullDetailsRecord.self
        case .bullPTA1:
            return PTARecord.self
        case .bullPTA2:
            return PTARecord.self
        case .bullPTA3:
            return PTARecord.self
        case .bullPTA4:
            return PTARecord.self
        case .bullPTA5:
            return PTARecord.self
        case .bullPTA6:
            return PTARecord.self
        case .bullPTA7:
            return PTARecord.self
        case .deadDamDetails:
            return DeadDamRecord.self
        case .deadDamPTA1:
            return PTARecord.self
        case .deadDamPTA2:
            return PTARecord.self
        case .deadDamPTA3:
            return PTARecord.self
        case .deadDamPTA4:
            return PTARecord.self
        case .deadDamPTA5:
            return PTARecord.self
        case .deadDamPTA6:
            return PTARecord.self
        case .deadDamPTA7:
            return SomeRecord.self
        case .weighCalendarLeader:
            return WeighingCalendarLeaderRecord.self
        case .weighCalendarQuarter:
            return WeighingQuarterRecord.self
        case .weighCalendarTrailer:
            return WeighingCalendarEndRecord.self
        case .breedRecord1:
            return BreedPart1Record.self
        case .breedRecord2:
            return BreedPart2Record.self
        case .breedRecord3:
            return BreedPart3Record.self
        }
    }
}

// MARK: -

/// A section within a Datastream file
public enum RecordSection: String {
    case herd         = "H"
    case animal       = "C"
    case statement    = "S"
    case lactation    = "L"
    case bullIdentity = "B"
    case damIdentity  = "D"
    case breedFileAndWeighingCalendar = "W"
}
