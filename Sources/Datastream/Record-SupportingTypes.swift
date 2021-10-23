//
//  Record-SupportingTypes.swift
//  
//
//  Created by Ben Barnett on 22/10/2021.
//

import Foundation

internal struct RecordConstants {
    static let recordLength = 76
    static let descriptorField = Field(location: 0, length: 2)
    static let checksumField = Field(location: 71, length: 5)
}

public enum RecordingScheme: Int {
    case premium   = 1
    case cmr       = 2
    case pmr       = 3
    case fmr       = 4
    case goats     = 5
    case isleOfMan = 6
    case jersey    = 7
    case guernsey  = 8
    case standard1 = 11
    case standard2 = 12
    case standard3 = 13
    case standard4 = 14
    case basic1    = 15
    case basic2    = 16
}

public enum ServiceType: String {
    case automatic = "A"
    case manual    = "M"
    case unknown   = " "
}

public enum CowCardPrinting: Int {
    case none       = 0
    case end305     = 1
    case endNatural = 2
    case both       = 3
}

public enum CellCountMembership: Int {
    case notaMember    = 0
    case currentMember = 1
    case resigned      = 3 // There is no two
}
