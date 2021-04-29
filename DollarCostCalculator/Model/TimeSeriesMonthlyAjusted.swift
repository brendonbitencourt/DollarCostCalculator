//
//  TimeSeriesMonthlyAjusted.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import Foundation

struct TimeSeriesMonthlyAjusted: Codable {
    let meta: Meta
    let timeSeries: [String: OHLC]
    
    enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }
    
    func getMonthInfos() -> [MonthInfo] {
        var monthInfos = [MonthInfo]()
        let sortedTimeSeries = timeSeries.sorted(by: { $0.key > $1.key })
        monthInfos = sortedTimeSeries.map { (dateString, ohlc) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dateString)!
            let ajustedCloseDouble = Double(ohlc.ajustedClose)!
            let monthInfo = MonthInfo(date: date, ajustedOpen: ohlc.ajustedOpen, ajustedClose: ajustedCloseDouble)
            return monthInfo
        }
        return monthInfos
    }
}

struct MonthInfo {
    let date: Date
    let ajustedOpen: Double
    let ajustedClose: Double
}

struct Meta: Codable {
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OHLC: Codable {
    let open: String
    let close: String
    let ajustedClose: String
    var ajustedOpen: Double {
        let doubleOpen = Double(self.open)!
        let doubleAjustedClose = Double(self.ajustedClose)!
        let doubleClose = Double(self.close)!
        return doubleOpen * (doubleAjustedClose / doubleClose)
    }
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case close = "4. close"
        case ajustedClose = "5. adjusted close"
    }
}
