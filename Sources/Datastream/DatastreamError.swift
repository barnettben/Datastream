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
    
    /// A message describing the encountered error
    public var message: String?
    
    /// Provides context for the given error code
    ///
    /// This may differ depending on the particular error type.
    /// For example, it could be the content of a record or a particular field
    public var context: String?
    
    /// Creates a new DatastreamError
    public init(code: ErrorCode, message: String? = nil, context: String? = nil) {
        self.code = code
        self.message = message
        self.context = context
    }
}

extension DatastreamError: LocalizedError {
    public var errorDescription: String? {
        return message ?? String(describing: code)
    }
}

/// A parsing error type
public enum ErrorCode {
    
    /// Thrown when a record of incorrect length is encountered
    case invalidLength
    
    /// Thrown when a record has an invalid checksum
    case invalidChecksum
    
    /// Thrown when converting a field to the required type (eg. String -> Int) fails.
    case invalidContentType
    
    /// Thrown when a record has an identifier not in the specification
    case unknownIdentifier
    
    /// A catch-all error for problems with the format of the data file
    ///
    /// A message should provide further details about the problem
    case malformedInput
    
    /// An unknown error. A message should be provided to provide further details.
    case unknown
}
