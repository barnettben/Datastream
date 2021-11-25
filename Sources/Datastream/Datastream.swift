//
//  Datastream.swift
//
//
//  Created by Ben Barnett on 19/10/2021.
//

import Foundation

/// Represents the contents of a Datastream file
public struct Datastream {
    
    /// Details about this milking herd
    public var herdDetails: HerdDetails
    
    /// Summaries of all milk recordings
    public var recordings: [HerdRecording]
    
    /// Animals currently recorded within this herd
    public var animals: [Animal]
    
    /// The NMR identity number of this herd
    public var nmrHerdNumber: String
    
    /// Production- and event-related information for animals within the herd
    public var statements: [AnimalStatement]
    
    /// Completed lactations for animals within the herd
    public var lactations: [Lactation]
    
    /// Details of sires referred to within the `animals` and `statements` sections
    public var bulls: [BullDetails]
    
    /// Dead female ancestors of animals currently in the herd
    public var deadDams: [DeadDam]
    
    /// The current NMR weighing calendar
    public var weighingCalendar: WeighingCalendar
    
    /// Current NMR breed information
    public var breeds: [Breed]
}

extension Datastream {
    
    /// Asynchronously creates a new `Datastream` from a file at a given URL
    ///
    /// - Parameter url: The location of a Datastream file
    /// - Throws: `DatastreamError`
    public init(url: URL) async throws {
        self = try await DatastreamParser(url: url).parse()
    }
    
    /// Creates a new `Datastream` from a file at a given URL
    ///
    /// - Parameter url: The location of a Datastream file
    /// - Throws: `DatastreamError`
    public init(url: URL) throws {
        self = try DatastreamParser(url: url).parse()
    }
}
