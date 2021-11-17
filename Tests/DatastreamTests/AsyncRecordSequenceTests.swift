//
//  AsyncRecordSequenceTests.swift
//  
//
//  Created by Ben Barnett on 17/11/2021.
//

import XCTest
@testable import Datastream

final class AsyncRecordSequenceTests: XCTestCase {
    
    func testSequenceReturnsValues() async throws {
        let fileURL = Bundle.module.url(forResource: "DSMEMBER", withExtension: "DAT")!
        let sequence = AsyncRecordSequence(url: fileURL)
        // First 10 just to check
        for try await record in sequence.prefix(10) {
            XCTAssertNotNil(record)
        }
    }
    
    func testValidatesDemoFile() async throws {
        let fileURL = Bundle.module.url(forResource: "DSMEMBER", withExtension: "DAT")!
        var sequence = AsyncRecordSequence(url: fileURL)
        sequence.validateRecords = true
        for try await record in sequence {
            XCTAssertNotNil(record)
        }
    }
    
    func testFailsInvalidRecords() async throws {
        let fileURL = Bundle.module.url(forResource: "InvalidRecords", withExtension: "txt")!
        var sequence = AsyncRecordSequence(url: fileURL)
        sequence.validateRecords = true
        var iterator = sequence.makeAsyncIterator()
        
        do {
            let _ = try await iterator.next()
            XCTFail("Error should have been thrown")
        } catch let error as DatastreamError {
            XCTAssertEqual(error.code, .invalidChecksum)
        }
        do {
            let _ = try await iterator.next()
            XCTFail("Error should have been thrown")
        } catch let error as DatastreamError {
            XCTAssertEqual(error.code, .invalidLength)
        }
        do {
            let _ = try await iterator.next()
            XCTFail("Error should have been thrown")
        } catch let error as DatastreamError {
            XCTAssertEqual(error.code, .invalidLength)
        }
    }
}
