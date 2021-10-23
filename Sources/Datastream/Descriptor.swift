//
//  Descriptor.swift
//  
//
//  Created by Ben Barnett on 17/10/2021.
//

import Foundation

public enum RecordDescriptor: String {
    
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
    case recordingRecord1 = "HD"
    case recordingRecord2 = "HE"
    
    // MARK: Cow details
    case animalIdentity     = "C1"
    case animalOtherDetails = "C2"
    case animalName         = "C3"
    case animalSireDam      = "C4"
    case animalPTA          = "C5"
    
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
    case lactationPossibleNaturalTotals = "L5"
    
    // MARK: Sire details section
    case bullDetails    = "B1"
    case bullEvalGroup1 = "B2" // Argh! Eval-group number doesn't match
    case bullEvalGroup2 = "B3" // the descriptor constant. This is correct,
    case bullEvalGroup3 = "B4" // but ugly. Same for D section below.
    case bullEvalGroup4 = "B5"
    case bullEvalGroup5 = "B6"
    case bullEvalGroup6 = "B7"
    case bullEvalGroup7 = "B8"
    
    // MARK: Dead dam section
    case deadDamDetails    = "D1"
    case deadDamEvalGroup1 = "D2"
    case deadDamEvalGroup2 = "D3"
    case deadDamEvalGroup3 = "D4"
    case deadDamEvalGroup4 = "D5"
    case deadDamEvalGroup5 = "D6"
    case deadDamEvalGroup6 = "D7"
    case deadDamEvalGroup7 = "D8"
    
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

extension RecordDescriptor {
    public var section: RecordSection {
        let descriptorPrefix = String(rawValue.first!)
        return RecordSection(rawValue: descriptorPrefix)!
    }
    
    /// Records types marked as being for internal use only
    public static var privateRecordDescriptors: [RecordDescriptor] {
        return [.header9, .headerA, .headerB, .headerC, .statementNMRUse, .statementMMBUse]
    }
}

extension RecordDescriptor {
    /// Provides a type for the struct which can represent the current record descriptor
    internal var recordType: Record.Type {
        switch self {
        case .nmrDetails:
            return NMRDetails.self
        case .address1:
            return TextRecord.self
        case .address2:
            return TextRecord.self
        case .address3:
            return TextRecord.self
        case .address4:
            return TextRecord.self
        case .address5:
            return TextRecord.self
        case .serviceIndicators:
            return ServiceIndicators.self
        case .serviceIndicatorsContinued:
            return ServiceIndicatorsContinued.self
        case .header9:
            return BaseRecord.self
        case .headerA:
            return BaseRecord.self
        case .headerB:
            return BaseRecord.self
        case .headerC:
            return BaseRecord.self
        case .recordingRecord1:
            return BaseRecord.self
        case .recordingRecord2:
            return BaseRecord.self
        case .animalIdentity:
            return BaseRecord.self
        case .animalOtherDetails:
            return BaseRecord.self
        case .animalName:
            return BaseRecord.self
        case .animalSireDam:
            return BaseRecord.self
        case .animalPTA:
            return BaseRecord.self
        case .statementSectionLeader:
            return BaseRecord.self
        case .cowIDRecord:
            return BaseRecord.self
        case .statementNMRUse:
            return BaseRecord.self
        case .currentLactationTotals:
            return BaseRecord.self
        case .statementMMBUse:
            return BaseRecord.self
        case .eventWeighing:
            return BaseRecord.self
        case .eventService:
            return BaseRecord.self
        case .eventActualCalving:
            return BaseRecord.self
        case .eventCalving3rdCalf:
            return BaseRecord.self
        case .eventAssumedCalving:
            return BaseRecord.self
        case .eventNoSample:
            return BaseRecord.self
        case .eventAssumed1x:
            return BaseRecord.self
        case .event1x:
            return BaseRecord.self
        case .eventAssumedDry:
            return BaseRecord.self
        case .eventDry:
            return BaseRecord.self
        case .eventSuckling:
            return BaseRecord.self
        case .eventAbsent:
            return BaseRecord.self
        case .eventBarren:
            return BaseRecord.self
        case .eventAbort:
            return BaseRecord.self
        case .eventSick:
            return BaseRecord.self
        case .eventLame:
            return BaseRecord.self
        case .eventMastitis:
            return BaseRecord.self
        case .eventDead:
            return BaseRecord.self
        case .eventSoldInPrevHerd:
            return BaseRecord.self
        case .eventSold:
            return BaseRecord.self
        case .lactationSectionLeader:
            return BaseRecord.self
        case .lactationFixedDetails:
            return BaseRecord.self
        case .calvingDetails:
            return BaseRecord.self
        case .calvingPossibleExtraCalves:
            return BaseRecord.self
        case .lactation305dTotals:
            return BaseRecord.self
        case .lactationPossibleNaturalTotals:
            return BaseRecord.self
        case .bullDetails:
            return BaseRecord.self
        case .bullEvalGroup1:
            return BaseRecord.self
        case .bullEvalGroup2:
            return BaseRecord.self
        case .bullEvalGroup3:
            return BaseRecord.self
        case .bullEvalGroup4:
            return BaseRecord.self
        case .bullEvalGroup5:
            return BaseRecord.self
        case .bullEvalGroup6:
            return BaseRecord.self
        case .bullEvalGroup7:
            return BaseRecord.self
        case .deadDamDetails:
            return BaseRecord.self
        case .deadDamEvalGroup1:
            return BaseRecord.self
        case .deadDamEvalGroup2:
            return BaseRecord.self
        case .deadDamEvalGroup3:
            return BaseRecord.self
        case .deadDamEvalGroup4:
            return BaseRecord.self
        case .deadDamEvalGroup5:
            return BaseRecord.self
        case .deadDamEvalGroup6:
            return BaseRecord.self
        case .deadDamEvalGroup7:
            return BaseRecord.self
        case .weighCalendarLeader:
            return BaseRecord.self
        case .weighCalendarQuarter:
            return BaseRecord.self
        case .weighCalendarTrailer:
            return BaseRecord.self
        case .breedRecord1:
            return BaseRecord.self
        case .breedRecord2:
            return BaseRecord.self
        case .breedRecord3:
            return BaseRecord.self
        }
    }
}

// MARK: -

public enum RecordSection: String {
    case herd         = "H"
    case animal       = "C"
    case statement    = "S"
    case lactation    = "L"
    case bullIdentity = "B"
    case damIdentity  = "D"
    case breedFileAndWeighingCalendar = "W"
}
