//
//  AsyncRecordSequence.swift
//  
//
//  Created by Ben Barnett on 17/11/2021.
//

import Foundation


/// `AsyncRecordSequence` produces instances of the `Record` protocol
/// from a datastream file.
public struct AsyncRecordSequence: AsyncSequence {
    
    public typealias Element = Record
    private var fileURL: URL
    
    /// Whether record size and checksums should be validated during parsing
    ///
    /// This is rarely necessary and off by default.
    public var validateRecords: Bool = false
    
    /// Initializes a new async sequence from a URL
    public init(url: URL) {
        self.fileURL = url
    }
    
    public struct AsyncRecordIterator : AsyncIteratorProtocol {
        /*
         Since datastream files are line-based, this iterator just
         wraps a URL.lines iterator and then creates a record from each
         line produced.
         */
        private var fileURL: URL
        private var lineIterator: AsyncLineSequence<URL.AsyncBytes>.AsyncIterator
        
        /// Whether record size and checksums should be validated during parsing
        public var validateRecords: Bool = false
        
        public init(fileURL: URL, validatesRecords: Bool = false) {
            self.fileURL = fileURL
            self.lineIterator = fileURL.lines.makeAsyncIterator()
            self.validateRecords = validatesRecords
        }
        
        /// Asynchronously advances to the next element and returns it, or ends the
        /// sequence if there is no next element.
        ///
        /// - Returns: The next element, if it exists, or `nil` if the sequence end has been reached.
        public mutating func next() async throws -> Record? {
            
            // `lineIterator` strips out line breaks, so we don't have to do that ourselves
            guard let line = try await lineIterator.next(), line.isEmpty == false else {
                return nil
            }
            guard let recordIdentifier = RecordIdentifier(rawValue: String(line.prefix(2))) else {
                throw DatastreamError(code: .unknownIdentifier, message: "Record begins with unknown identifier '\(line.prefix(2))'.", context: line)
            }
            let record: Record
            if validateRecords == true {
                record = try recordIdentifier.recordType.init(validatingString: line)
            } else {
                record = try recordIdentifier.recordType.init(string: line)
            }
            return record
        }
    }

    /// Creates the asynchronous iterator that produces elements of this
    /// asynchronous sequence.
    ///
    /// - Parameter fileURL: A URL pointing to a Datastream file
    /// - Parameter validatesRecords: `true` if record size and checksums should be validated during parsing. `false` by default.
    /// - Returns: An instance of the `AsyncIterator` type used to produce
    /// elements of the asynchronous sequence.
    public func makeAsyncIterator() -> AsyncRecordIterator {
        return AsyncRecordIterator(fileURL: fileURL, validatesRecords: validateRecords)
    }
    
    /// The type of asynchronous iterator that produces elements of this
    /// asynchronous sequence.
    public typealias AsyncIterator = AsyncRecordIterator
}
