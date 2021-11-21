//
//  DatastreamConvenience.swift
//  
//
//  Created by Ben Barnett on 21/11/2021.
//

import Foundation

extension Array where Element == Breed {
    
    /// Returns the first breed matching the provided code, if present
    public func first(withBreedCode code: Int) -> Breed? {
        return first(where: { $0.code == code })
    }
}
