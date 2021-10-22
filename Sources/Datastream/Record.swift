//
//  Record.swift
//  
//
//  Created by Ben Barnett on 18/10/2021.
//

import Foundation


/// The minimal properties of a datasteam record item
///
/// All datastream records start with a record descriptor and end with a checksum.
/// Content between these two varies between record types.
///
/// See ``BaseRecord`` for a minimal `Record` implementation
///
/// - Note: Records are not necessarily required to have a valid checksum
public protocol Record {
    var descriptor: RecordDescriptor { get }
    var checksum: Int { get }
    
    var checksumIsValid: Bool { get }
}


extension Record {
    
    /// Reports if a given string matches the specification of a record
    ///
    /// It must be 76 ascii characters long and have a valid checksum
    /// - Parameter content: A string to check for validity
    /// - Returns: `true` if valid, `false` if not
    public static func validateRecordString(_ content: String) -> Bool {
        return validateRecordLength(content) && validateRecordStringChecksum(content)
    }
    
    /// Reports if a given string is the correct length to be a record
    ///
    /// It must be 76 ascii characters long
    /// - Parameter content: A string to check for validity
    /// - Returns: `true` if valid, `false` if not
    public static func validateRecordLength(_ content: String) -> Bool {
        return (content.lengthOfBytes(using: .ascii) == RecordConstants.recordLength)
    }
    
    /// Reports if a given record string has a valid checksum
    /// - Parameter content: A record string to validate for checksum correctness
    /// - Returns: `true` if valid, `false` if not
    public static func validateRecordStringChecksum(_ content: String) -> Bool {
        do {
            let endOffset = content.index(content.endIndex, offsetBy: -RecordConstants.checksumField.length)
            let contentToCheck = content.prefix(upTo: endOffset)
            let expected: Int = try RecordConstants.checksumField.extractValue(from: content)
            return (expected == contentToCheck.asciiValues.map({ Int($0) }).reduce(0, +))
        } catch {
            return false
        }
    }
}


/// A basic implementation of a datasteam record item
///
/// Implements `Record`. It also provides:
/// - A variable containing the string comprising this record
/// - An initializer to build a `BaseRecord` from a string
public struct BaseRecord: Record {
    private(set) public var descriptor: RecordDescriptor
    private(set) public var content: String
    private(set) public var checksum: Int
    
    public var checksumIsValid: Bool {
        let checksumString = String(format: "%05d", checksum)
        let stringValue = "\(descriptor.rawValue),\(content),\(checksumString)"
        return BaseRecord.validateRecordStringChecksum(stringValue)
    }
    
    init(string value: String) throws {
        guard BaseRecord.validateRecordLength(value) else {
            throw DatastreamError(code: .invalidLength, recordContent: value)
        }
        
        descriptor = try RecordConstants.descriptorField.extractValue(from: value)
        content = value
        checksum = try RecordConstants.checksumField.extractValue(from: value)
    }
}
