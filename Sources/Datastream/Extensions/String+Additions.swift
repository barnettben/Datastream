//
//  String+Additions.swift
//  
//
//  Created by Ben Barnett on 18/10/2021.
//

import Foundation

extension StringProtocol {
    
    /// Returns an array containing all characters that can be represented by an
    /// ascii codepoint as `UInt8`.
    ///
    /// Non-ascii characters are silently skipped and not included in the returned array.
    ///
    ///     let str = "abc"
    ///     print(str.asciiValues)
    ///     // Prints "[97, 98, 99]"
    ///
    /// - Returns: An array of decimal ascii values as `UInt8`
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
