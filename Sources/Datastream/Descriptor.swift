//
//  Descriptor.swift
//  
//
//  Created by Ben Barnett on 17/10/2021.
//

import Foundation

/// Represents the type of a given record
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
    case lactationNaturalTotals = "L5"
    
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

extension RecordDescriptor: CaseIterable {
}

extension RecordDescriptor {
    public var section: RecordSection {
        let descriptorPrefix = String(rawValue.first!)
        return RecordSection(rawValue: descriptorPrefix)!
    }
    public var isPrivateUse: Bool {
        return RecordDescriptor.privateRecordDescriptors.contains(self)
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
            return StatementHeaderRecord.self
        case .cowIDRecord:
            return CowIDRecord.self
        case .statementNMRUse:
            return BaseRecord.self
        case .currentLactationTotals:
            return LactationDetailsRecord.self
        case .statementMMBUse:
            return BaseRecord.self
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
            return BaseRecord.self
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
