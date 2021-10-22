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

