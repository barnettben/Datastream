//
//  DatastreamParser.swift
//  
//
//  Created by Ben Barnett on 19/10/2021.
//

import Foundation

/// A parser of Datastream files
///
/// Provides sequential access to records within the file via the ``records`` property
public class DatastreamParser {
    
    private var fileURL: URL
    
    /// Returns a parser for reading a datastream file at the provided URL.
    public init(url: URL) {
        self.fileURL = url
    }
    
    /// The datastream file contents, as an asynchronous sequence of `Record`s.
    public var records: AsyncRecords {
        return AsyncRecords(url: fileURL)
    }
}

extension DatastreamParser {
    
    /// The `AsyncRecords` sequence produces instances of the `Record` protocol
    /// from a datastream file.
    public struct AsyncRecords: AsyncSequence {
        
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
        public typealias AsyncIterator = DatastreamParser.AsyncRecords.AsyncRecordIterator
    }
}


