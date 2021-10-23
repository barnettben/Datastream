//
//  RecordTests.swift
//  
//
//  Created by Ben Barnett on 18/10/2021.
//

import XCTest
@testable import Datastream

final class RecordTests: XCTestCase {
    
    static let goodRecordStrings = [
        "H1,69,01,15,14,11,00,00,00,00,00,89000,01,FOR DEMO USE ONLY   ,880201,,03750",
        "H4,                                   ,                               ,02368",
        "W4,01,01,HOLSTEIN                 ,HF,280,001,030,750,999,            ,03274"
        ]
    static let invalidChecksumRecordStrings = [
        "H1,69,01,15,14,11,00,00,00,00,00,89000,01,FOR DEMO USE ONLY   ,880201,,09999",
        "H4,                                   ,                               ,01234",
        "W4,01,01,HOLSTEIN                 ,HF,280,001,030,750,999,            ,43210"
        ]
    static let invalidLengthRecordStrings = [
        "H1,69,01,15,14,11,00,00,00,00,00,89000,01,FOR DEMO USE ONLY TOO LONG,880201,,03750",
        "H4, MISSING DIVIDING COMMA AND TOO SHORT                             02368",
        "W4,01,01,NOT LONG ENOUGH        ,HF,280,001,030,750,999,            ,03274"
        ]
    
    func testChecksumValidationOK() throws {
        for recordString in RecordTests.goodRecordStrings {
            XCTAssertTrue(BaseRecord.validateRecordStringChecksum(recordString))
        }
    }
    func testChecksumValidationFail() throws {
        for recordString in RecordTests.invalidChecksumRecordStrings {
            XCTAssertFalse(BaseRecord.validateRecordStringChecksum(recordString))
        }
    }
    func testRecordLengthValidation() throws {
        for recordString in RecordTests.goodRecordStrings {
            XCTAssertTrue(BaseRecord.validateRecordLength(recordString))
        }
        for recordString in RecordTests.invalidLengthRecordStrings {
            XCTAssertFalse(BaseRecord.validateRecordLength(recordString))
        }
    }
    
    func testBaseRecordCreationOK() throws {
        for recordString in RecordTests.goodRecordStrings {
            XCTAssertNoThrow(try BaseRecord(string: recordString))
        }
    }
    func testBaseRecordCreationFails() throws {
        for recordString in RecordTests.invalidLengthRecordStrings {
            XCTAssertThrowsError(try BaseRecord(string: recordString))
        }
    }
    
    func testNMRDetails() throws {
        let content = RecordTests.goodRecordStrings.first!
        let record = try NMRDetails(string: content)
        XCTAssertEqual(record.descriptor, .nmrDetails)
        XCTAssertEqual(record.nationalHerdMark, "89000")
        XCTAssertEqual(record.checksum, 3750)
    }
}
