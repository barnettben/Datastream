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
