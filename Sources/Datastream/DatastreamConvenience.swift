//
//  DatastreamConvenience.swift
//  
//
//  Created by Ben Barnett on 21/11/2021.
//

import Foundation

extension Array where Element == Breed {
    
    /// Returns the first breed matching the provided code, if present
    public func first(breedCode code: Int) -> Breed? {
        return first(where: { $0.code == code })
    }
}

extension Array where Element == AnimalStatement {
    
    /// Returns the first statement for an animal with a given line number
    public func first(lineNumber: String) -> AnimalStatement? {
        return first(where: { $0.lineNumber == lineNumber })
    }
}

extension Array where Element == Lactation {
    
    /// Returns the first lactation for an animal with a given line number
    public func first(lineNumber: String) -> Lactation? {
        return first(where: { $0.lineNumber == lineNumber })
    }
    
    /// Returns lactations for an animal with a given line number
    public func filter(lineNumber: String) -> [Lactation] {
        return filter({ $0.lineNumber == lineNumber })
    }
}
