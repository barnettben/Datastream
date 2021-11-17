//
//  File.swift
//  
//
//  Created by Ben Barnett on 13/11/2021.
//

import Foundation

public struct BullDetailsRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.bullDetails]
    }
    
    public var breed: Int
    public var identity: String
    public var longName: String
    public var shortName: String
    
    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        
        breed = try Field(location: 3, length: 2).extractValue(from: content)
        identity = try Field(location: 6, length: 12).extractValue(from: content)
        longName = try Field(location: 19, length: 40).extractValue(from: content)
        shortName = try Field(location: 60, length: 8).extractValue(from: content)
    }
}
