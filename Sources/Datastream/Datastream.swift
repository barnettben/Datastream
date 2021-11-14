//
//  Datastream.swift
//
//
//  Created by Ben Barnett on 19/10/2021.
//

import Foundation

/// Represents the contents of a Datastream file
public struct Datastream {
    public var herdDetails: HerdDetails
    public var recordings: [HerdRecording]
    public var animals: [Animal]
    public var nmrHerdNumber: String
    public var statements: [AnimalStatement]
    public var lactations: [Lactation]
    public var bulls: [BullDetails]
    public var deadDams: [DeadDam]
}

extension Datastream {
    
    /// Creates a new `Datastream` from a file at a given URL
    ///
    /// - Parameter url: The location of a Datastream file
    /// - Throws: `DatastreamError`
    public init(url: URL) async throws {
        self = try await DatastreamParser(url: url).parse()
    }
}

/// The `AsyncRecords` sequence produces instances of the `Record` protocol
/// from a datastream file.
public struct AsyncRecordSequence: AsyncSequence {
    
    public typealias Element = Record
    private var fileURL: URL
    
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
        
        public init(fileURL: URL) {
            self.fileURL = fileURL
            self.lineIterator = fileURL.lines.makeAsyncIterator()
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
            guard let descriptor = RecordDescriptor(rawValue: String(line.prefix(2))) else {
                throw DatastreamError(code: .unknownDescriptor, recordContent: line)
            }
            let record = try descriptor.recordType.init(string: line)
            return record
        }
    }

    /// Creates the asynchronous iterator that produces elements of this
    /// asynchronous sequence.
    ///
    /// - Returns: An instance of the `AsyncIterator` type used to produce
    /// elements of the asynchronous sequence.
    public func makeAsyncIterator() -> AsyncRecordIterator {
        return AsyncRecordIterator(fileURL: fileURL)
    }
    
    /// The type of asynchronous iterator that produces elements of this
    /// asynchronous sequence.
    public typealias AsyncIterator = AsyncRecordIterator
}
