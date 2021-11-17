//
//  File.swift
//  
//
//  Created by Ben Barnett on 14/11/2021.
//

import Foundation

public struct WeighingCalendarLeaderRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.weighCalendarLeader]
    }

    public var startYearAndMonth: String
    public var endYearAndMonth: String
    
    public var startDate: Date {
        let dateString = startYearAndMonth + "01"
        return DateFormatter.datastreamDateFormat.date(from: dateString)!
    }
    public var endDate: Date {
        let dateString = endYearAndMonth + "01"
        let firstDate = DateFormatter.datastreamDateFormat.date(from: dateString)!
        let lastDayComponents = DateComponents(month: 1, day: -1)
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: lastDayComponents, to: firstDate)!
    }

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        
        startYearAndMonth = try Field(location: 3, length: 4).extractValue(from: content)
        endYearAndMonth = try Field(location: 8, length: 4).extractValue(from: content)
    }
}

public struct WeighingQuarterRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.weighCalendarQuarter]
    }

    public var year1: Int
    public var sequence1: Int
    public var weighMonth1: Int
    public var calendarMonth1: Int
    public var pmDay1: Int
    public var amDay1: Int
    public var year2: Int
    public var sequence2: Int
    public var weighMonth2: Int
    public var calendarMonth2: Int
    public var pmDay2: Int
    public var amDay2: Int
    public var year3: Int
    public var sequence3: Int
    public var weighMonth3: Int
    public var calendarMonth3: Int
    public var pmDay3: Int
    public var amDay3: Int
    

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        
        year1 = try Field(location: 3, length: 2).extractValue(from: content)
        sequence1 = try Field(location: 6, length: 2).extractValue(from: content)
        weighMonth1 = try Field(location: 9, length: 2).extractValue(from: content)
        calendarMonth1 = try Field(location: 12, length: 2).extractValue(from: content)
        pmDay1 = try Field(location: 15, length: 2).extractValue(from: content)
        amDay1 = try Field(location: 18, length: 2).extractValue(from: content)
        year2 = try Field(location: 23, length: 2).extractValue(from: content)
        sequence2 = try Field(location: 26, length: 2).extractValue(from: content)
        weighMonth2 = try Field(location: 29, length: 2).extractValue(from: content)
        calendarMonth2 = try Field(location: 32, length: 2).extractValue(from: content)
        pmDay2 = try Field(location: 35, length: 2).extractValue(from: content)
        amDay2 = try Field(location: 38, length: 2).extractValue(from: content)
        year3 = try Field(location: 43, length: 2).extractValue(from: content)
        sequence3 = try Field(location: 46, length: 2).extractValue(from: content)
        weighMonth3 = try Field(location: 49, length: 2).extractValue(from: content)
        calendarMonth3 = try Field(location: 52, length: 2).extractValue(from: content)
        pmDay3 = try Field(location: 55, length: 2).extractValue(from: content)
        amDay3 = try Field(location: 58, length: 2).extractValue(from: content)
    }
}

public struct WeighingCalendarEndRecord: Record {
    public var recordIdentifier: RecordIdentifier
    public static var representableIdentifiers: [RecordIdentifier] {
        return [.weighCalendarTrailer]
    }

    public var numberOfWeighQuarters: Int
    

    public init(string content: String) throws {
        recordIdentifier = try Field.identifierField.extractValue(from: content)
        Self.assertCanRepresentRecordIdentifier(recordIdentifier)
        
        numberOfWeighQuarters = try Field(location: 3, length: 4).extractValue(from: content)
    }
}
