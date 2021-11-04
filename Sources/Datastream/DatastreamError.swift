//
//  RecordError.swift
//  
//
//  Created by Ben Barnett on 21/10/2021.
//

import Foundation

/// Represents a parsing error
public struct DatastreamError: Error {
    
    /// A code representing the type of error thrown
    public var code: ErrorCode
    
    /// Provides context for the given error code
    public var recordContent: String?
}

/// A parsing error type
public enum ErrorCode {
    
    case invalidLength
    case invalidChecksum
    case nonNumberChecksum
    
    /// Thrown when converting a field to the required type (eg. String -> Int) fails.
    case invalidContentType
    
    /// Thrown when a record has a descriptor not in the specification
    case unknownDescriptor
    
    /// A catch-all error for problems that don't merit a more specific description
    case malformedInput
}
