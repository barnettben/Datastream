//
//  Record.swift
//  
//
//  Created by Ben Barnett on 18/10/2021.
//

import Foundation


/// The minimal properties of a datasteam record item
///
/// All datastream records start with a record type and end with a checksum.
/// Content between these two varies between record types.
///
/// We do not include the checksum as a property on `Record` types as it is only relevant to this library
/// during the reading of a Datastream file.
///
/// See ``BaseRecord`` for a minimal `Record` implementation
///
/// - Note: Records are not necessarily required to have a valid checksum
public protocol Record {
    var recordIdentifier: RecordIdentifier { get }
    static var representableIdentifiers: [RecordIdentifier] { get }
    
    init(string content: String) throws
}

// MARK: - Validating
extension Record {
    
    /// Initializes a type conforming to `Record` if it is considered valid
    ///
    /// A record is considered valid if it is 76 ascii characters long and has a valid checksum.
    /// See ``recordChecksumIsValid(_:)`` for details of how this is calculated.
    ///
    public init(validatingString content: String) throws {
        guard Self.recordStringIsValid(content) == true else {
            throw DatastreamError(code: .invalidChecksum, recordContent: content)
        }
        try self.init(string: content)
    }
    
    /// Reports if a given string matches the specification of a record
    ///
    /// It must be 76 ascii characters long and have a valid checksum
    /// - Parameter content: A string to check for validity
    /// - Returns: `true` if valid, `false` if not
    public static func recordStringIsValid(_ content: String) -> Bool {
        return recordLengthIsValid(content) && recordChecksumIsValid(content)
    }
    
    /// Reports if a given string is the correct length to be a record
    ///
    /// It must be 76 ascii characters long
    /// - Parameter content: A string to check for validity
    /// - Returns: `true` if valid, `false` if not
    public static func recordLengthIsValid(_ content: String) -> Bool {
        return (content.lengthOfBytes(using: .ascii) == Field.recordLength)
    }
    
    /// Reports if a given record string has a valid checksum
    ///
    /// The checksum is located in the last five characters of a record and is zero-padded (eg `01234`).
    ///
    /// It is calculated by summing the decimal ascii values of all characters in the record except for the
    /// last five used in the checksum itself. It is only relevant when reading or writing a file.
    ///
    /// - Parameter content: A record string to validate for checksum correctness
    /// - Returns: `true` if valid, `false` if not
    public static func recordChecksumIsValid(_ content: String) -> Bool {
        do {
            let endOffset = content.index(content.endIndex, offsetBy: -Field.checksumField.length)
            let contentToCheck = content.prefix(upTo: endOffset)
            let expected: Int = try Field.checksumField.extractValue(from: content)
            return (expected == contentToCheck.asciiValues.map({ Int($0) }).reduce(0, +))
        } catch {
            return false
        }
    }
}

extension Record {
    internal static func assertCanRepresentRecordIdentifier(_ recordIdentifier: RecordIdentifier) {
        guard self.representableIdentifiers.contains(recordIdentifier) else {
            fatalError("Attempting to create \(type(of: self)) with wrong record type: \(recordIdentifier)")
        }
    }
}

// MARK: -
extension Array where Array.Element == Record {
    /// Returns the first record of a given type, if present
    ///
    /// - Parameter typed: A type conforming to Record to search for
    /// - Returns: A `Record` of type `T`  if present, `nil` otherwise
    @inlinable public func first<T: Record>(typed: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
    /// Returns the first record of a given Type and RecordIdentifier, if present
    ///
    /// Useful when searching for a `Record` that can represent multiple RecordIdentifier types
    ///
    /// - Parameter typed: A type conforming to Record to search for
    /// - Parameter recordIdentifier: A ``RecordIdentifier`` to search for
    /// - Returns: A `Record` of type `T`  if present, `nil` otherwise
    @inlinable public func first<T: Record>(typed: T.Type, identifiedBy recordIdentifier: RecordIdentifier) -> T? {
        return first(where: { $0 is T && $0.recordIdentifier == recordIdentifier }) as? T
    }
}

// MARK: -

/// A basic implementation of a datasteam record item
///
/// Implements `Record` and provides a `String` value of it's content.
/// Used for undocumented or unknown record types.
public struct SomeRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public var content: String
    public static var representableIdentifiers: [RecordIdentifier] {
        return RecordIdentifier.allCases
    }
    
    public init(string content: String) throws {
        guard SomeRecord.recordLengthIsValid(content) else {
            throw DatastreamError(code: .invalidLength, recordContent: content)
        }
        
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        self.content = content
    }
}
