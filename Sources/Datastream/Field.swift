//
//  Field.swift
//  
//
//  Created by Ben Barnett on 22/10/2021.
//

import Foundation

/*
 At the moment, `Field` is an implementation detail. It's only use is for
 extracting information into a record type and doesn't need to be surfaced to
 users of the library.
 */

/// An item identifying the location of an entry within a record string
struct Field {
    var location: Int
    var length: Int
    
    init(location: Int, length: Int) {
        precondition(location >= 0, "Field cannot start below index 0.")
        precondition(length >= 1, "Field must have a length of at least 1.")
        precondition(location + length <= RecordConstants.recordLength, "Field trying to access location (\(location),\(length)) beyond limit of \(RecordConstants.recordLength).")
        
        self.location = location
        self.length = length
    }
}

extension Field {
    func extractValue(from content: String) throws -> String {
        assert(content.lengthOfBytes(using: .ascii) == RecordConstants.recordLength)
        let fieldStart = content.index(content.startIndex, offsetBy: location)
        let fieldEnd = content.index(fieldStart, offsetBy: length)
        return String(content[fieldStart ..< fieldEnd])
    }
    func extractValue(from content: String) throws -> Int {
        let field: String = try extractValue(from: content)
        guard let value = Int(field) else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        return value
    }
    func extractValue(from content: String) throws -> Bool {
        let field: String = try extractValue(from: content)
        guard field.lengthOfBytes(using: .ascii) == 1 else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        // Flag fields can be empty, 1/0, or Y/N. If empty, 0 or N, say false. All others true.
        return !(field.isEmpty || field == "0" || field == "N")
    }
    func extractValue(from content: String) throws -> Date {
        let field: String = try extractValue(from: content)
        guard let value = DateFormatter.datastreamDateFormat.date(from: field) else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        return value
    }
    
    func extractValue(from content: String) throws -> RecordDescriptor {
        let field: String = try extractValue(from: content)
        guard let value = RecordDescriptor(rawValue: field) else {
            throw DatastreamError.init(code: .unknownDescriptor, recordContent: content)
        }
        return value
    }
    func extractValue(from content: String) throws -> RecordingScheme {
        let field: Int = try extractValue(from: content)
        guard let value = RecordingScheme(rawValue: field) else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        return value
    }
    func extractValue(from content: String) throws -> ServiceType {
        let field: String = try extractValue(from: content)
        guard let value = ServiceType(rawValue: field) else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        return value
    }
    func extractValue(from content: String) throws -> CowCardPrinting {
        let field: Int = try extractValue(from: content)
        guard let value = CowCardPrinting(rawValue: field) else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        return value
    }
    func extractValue(from content: String) throws -> CellCountMembership {
        let field: Int = try extractValue(from: content)
        guard let value = CellCountMembership(rawValue: field) else {
            throw DatastreamError.init(code: .invalidContentType, recordContent: content)
        }
        return value
    }
}
