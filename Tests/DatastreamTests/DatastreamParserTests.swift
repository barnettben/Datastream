//
//  DatastreamParserTests.swift
//  
//
//  Created by Ben Barnett on 19/10/2021.
//

import XCTest
@testable import Datastream

final class DatastreamParserTests: XCTestCase {
    
    func testStructSpecialising() async throws {
        let fileURL = Bundle.module.url(forResource: "DSMEMBER", withExtension: "DAT")!
        let parser = DatastreamParser(url: fileURL)
        
        var iterator = parser.records.makeAsyncIterator()
        var currentRecord = try await iterator.next()
        XCTAssertTrue(currentRecord is NMRDetails)
        currentRecord = try await iterator.next()
        XCTAssertTrue(currentRecord is AddressRecord)
        currentRecord = try await iterator.next()
        XCTAssertTrue(currentRecord is AddressRecord)
    }
    
    func testParser() async {
        let fileURL = Bundle.module.url(forResource: "DSMEMBER", withExtension: "DAT")!
        let parser = DatastreamParser(url: fileURL)
        do {
            let content = try await parser.parse()
            XCTAssertEqual(content.recordings.count, 224)
            XCTAssertEqual(content.animals.count, 503)
            XCTAssertEqual(content.statements.count, 355)
            XCTAssertEqual(content.lactations.count, 535)
            XCTAssertEqual(content.bulls.count, 67)
            XCTAssertEqual(content.deadDams.count, 191)
            XCTAssertEqual(content.weighingCalendar.weighingDates.count, 2304)
            XCTAssertEqual(content.breeds.count, 99)
        } catch let error as DatastreamError {
            XCTFail(error.localizedDescription)
            return
        } catch {
            XCTFail("Non-Datastream error thrown: \(error)")
            return
        }
    }
}
