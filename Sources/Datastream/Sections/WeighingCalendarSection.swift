//
//  WeighingCalendarSection.swift
//  
//
//  Created by Ben Barnett on 14/11/2021.
//

import Foundation

/// Details about milk recording calendars and sequences
///
/// The weighing calendar is used for to plan recording dates on farm.
/// Each farm has a recording sequence number
/// (see ``NMRDetails``.``NMRDetails/weighingSequence``).
/// From this you can look up recording dates for that sequence in the `WeighingCalendar`.
///
/// NMR publish the current calendar [on their website](https://www.nmr.co.uk/production/recording-calendar)
public struct WeighingCalendar {
    
    /// The start date of this calendar
    public var startDate: Date
    
    /// The end date of this calendar
    public var endDate: Date
    
    /// All weighing dates contained within this calendar
    public var weighingDates: [WeighingDate]
}

/// An individual milk recording date
public struct WeighingDate {
    
    /// The year of this weighing
    public var recordingYear: Int
    
    /// The sequence to which this weighing belongs
    public var sequence: Int
    
    /// The sequence month of this weighing
    ///
    /// The calendar date and sequence date may differ if the recording falls just
    /// either side of a month boundary. This property allocates the weighing to
    /// the correct sequence month
    public var sequenceMonth: Int
    
    /// The calendar month of this weighing
    public var calendarMonth: Int
    
    /// The day of month for the PM weighing
    ///
    /// This is the official recording date
    public var pmWeighingDay: Int
    
    /// the day of month for the AM weighing
    public var amWeighingDay: Int
}
