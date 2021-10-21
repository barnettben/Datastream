//
//  RecordError.swift
//  
//
//  Created by Ben Barnett on 21/10/2021.
//

import Foundation

public struct DatastreamError: Error {
    
    public var code: ErrorCode
    public var recordContent: String?
}

public enum ErrorCode {
    case invalidLength
    case invalidChecksum
    case nonNumberChecksum
    case notEnoughRecordSections
    case invalidContentCount
    case unknownDescriptor
}
