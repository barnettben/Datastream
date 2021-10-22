//
//  DateFormatter+Additions.swift
//  
//
//  Created by Ben Barnett on 21/10/2021.
//

import Foundation

extension DateFormatter {
    static let datastreamDateFormat: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyMMdd"
        return df
    }()
}
