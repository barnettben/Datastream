//
//  StringAdditionsTests.swift
//  
//
//  Created by Ben Barnett on 18/10/2021.
//

import XCTest
@testable import Datastream

final class StringAdditionsTests: XCTestCase {
    func testAsciiValues() throws {
        let expected: [UInt8] = [97, 98, 99]
        XCTAssertEqual("abc".asciiValues, expected)
    }
    
    func testNonAsciiValues() throws {
        let expected: [UInt8] = [97, 98, 99]
        XCTAssertEqual("abc™".asciiValues, expected)
    }
}
