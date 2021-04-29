//
//  Date+Extensions.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import Foundation

extension Date {
    
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
}
