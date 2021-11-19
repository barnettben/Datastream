//
//  Field.swift
//  
//
//  Created by Ben Barnett on 22/10/2021.
//

import Foundation

/// Used to identify the location and extract the content of an entry within a record string
///
/// Datastream files are ascii-only so we can use integer offsets and lengths
///
/// For example:
/// ```
/// let input = "1,2,3,hello,5,6"
/// let field = Field(location: 6, length: 5)
/// let result: String = field.extractValue(from: input)
/// print(result) // hello
/// ```
struct Field {
    
    /// The offset within a String
    var location: Int
    
    /// The number of ascii characters in the record
    var length: Int
    
    /// A number to divide the originally loaded value by
    /// to produce the desired value
    ///
    /// Many numeric values in a Datastream are floating-point numbers
    /// stored as an integer string. The location of the decimal point is
    /// defined in the spec but not indicated in the file itself.
    ///
    /// To achieve the corrected value, we can optionally provide a divisor
    /// to get the desired result.
    ///
    /// Since we are applying this to both `Int` and `Double` types, and
    /// we are just using multiples of 10, we can use an `Int`.
    var divisor: Int?
    
    init(location: Int, length: Int, divisor: Int? = nil) {
        precondition(location >= 0, "Field cannot start below index 0.")
        precondition(length >= 1, "Field must have a length of at least 1.")
        precondition(location + length <= Self.recordLength, "Field trying to access location (\(location),\(length)) beyond limit of \(Self.recordLength).")
        precondition((divisor ?? 1) > 0, "Divisor must be greater than 0.")
        precondition((divisor ?? 10) % 10 == 0, "Divisor must be a multiple of 10.")
        
        self.location = location
        self.length = length
        self.divisor = divisor
    }
}

// MARK: - Constants
extension Field {
    
    /// Constant details of the identifier field
    static let identifierField = Field(location: 0, length: 2)
    
    /// Constant details of the checksum field
    static let checksumField = Field(location: 71, length: 5)
    
    /// Fixed size of a record
    static let recordLength = 76
}

// MARK: - Value extracting
extension Field {
    
    // Standard library types
    // ---
    
    /// This is the base field-extracting function
    ///
    /// It just gets the text out and doesn't change it
    private func extractRawValue(from content: String) throws -> String {
        assert(content.lengthOfBytes(using: .ascii) == Self.recordLength)
        let fieldStart = content.index(content.startIndex, offsetBy: location)
        let fieldEnd = content.index(fieldStart, offsetBy: length)
        return String(content[fieldStart ..< fieldEnd])
    }
    
    /// Returns a whitespace-trimmed string
    func extractValue(from content: String) throws -> String {
        let rawValue = try extractRawValue(from: content)
        return rawValue.trimmingCharacters(in: .whitespaces)
    }
    func extractValue(from content: String) throws -> Character {
        let strValue: String = try extractRawValue(from: content)
        guard let value = strValue.first else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create Character from String for \(self)", context: content)
        }
        return value
    }
    func extractValue(from content: String) throws -> Int {
        let strValue: String = try extractRawValue(from: content)
        guard var value = Int(strValue) else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create Int from '\(strValue)' for \(self)", context: content)
        }
        if let divisor = divisor {
            value = value / divisor
        }
        return value
    }
    func extractValue(from content: String) throws -> Double {
        let strValue: String = try extractRawValue(from: content)
        guard var value = Double(strValue) else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create Double from '\(strValue)' for \(self)", context: content)
        }
        if let divisor = divisor {
            value = value / Double(divisor)
        }
        return value
    }
    func extractValue(from content: String) throws -> Bool {
        let strValue: String = try extractRawValue(from: content)
        guard strValue.lengthOfBytes(using: .ascii) == 1 else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create Bool from '\(strValue)' for \(self)", context: content)
        }
        // Flag fields can be empty, 1/0, or Y/N. If empty, 0 or N, say false. All others true.
        return !(strValue.isEmpty || strValue == "0" || strValue == "N")
    }
    func extractValue(from content: String) throws -> Date? {
        let strValue: String = try extractRawValue(from: content)
        return DateFormatter.datastreamDateFormat.date(from: strValue)
    }
    func extractValue(from content: String) throws -> Date {
        let optionalValue: Date? = try extractValue(from: content)
        guard let value = optionalValue else {
            let strValue: String = try extractRawValue(from: content)
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create Date from '\(strValue)' for \(self)", context: content)
        }
        return value
    }
    
    // Generic enum-building extractors
    // Can we merge these into one?
    func extractValue<T: RawRepresentable>(from content: String) throws -> T where T.RawValue == Int {
        let intValue: Int = try extractValue(from: content)
        guard let typedValue = T(rawValue: intValue) else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create \(type(of: T.self)) from '\(intValue)' for \(self)", context: content)
        }
        return typedValue
    }
    func extractValue<T: RawRepresentable>(from content: String) throws -> T where T.RawValue == String {
        let strValue: String = try extractRawValue(from: content)
        guard let typedValue = T(rawValue: strValue) else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create \(type(of: T.self)) from '\(strValue)' for \(self)", context: content)
        }
        return typedValue
    }
    func extractValue<T: RawRepresentable>(from content: String) throws -> T where T.RawValue == Character {
        let charValue: Character = try extractValue(from: content)
        guard let typedValue = T(rawValue: charValue) else {
            throw DatastreamError.init(code: .invalidContentType, message: "Unable to create \(type(of: T.self)) from '\(charValue)' for \(self)", context: content)
        }
        return typedValue
    }
    func extractValue<T: RawRepresentable>(from content: String) throws -> T? where T.RawValue == Character {
        let charValue: Character = try extractValue(from: content)
        return T(rawValue: charValue)
    }
}

extension Field: CustomStringConvertible {
    var description: String {
        return "Field(\(location),\(length))"
    }
}
