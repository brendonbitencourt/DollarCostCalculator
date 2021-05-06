//
//  DCAService.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-05-04.
//

import Foundation

struct DCAService {
    
    func calculate(asset: Asset,
                   initialInvestimentAmount: Double,
                   monthlyDollarCostAveraging: Double,
                   initialDateOfInvestimentIndex: Int) -> DCAResult {
        
        let investimentAmount = getInvestimentAmount(initialInvestimentAmount,
                                                     monthlyDollarCostAveraging,
                                                     initialDateOfInvestimentIndex)
        let latestSharePrice = getLatestSharePrice(asset)
        let numberOfShares = getNumberOfShares(asset,
                                               initialInvestimentAmount,
                                               monthlyDollarCostAveraging,
                                               initialDateOfInvestimentIndex)
        let currentValue = getCurrentValue(numberOfShares, latestSharePrice)
        let annualReturn = getAnnualReturn(currentValue, investimentAmount, initialDateOfInvestimentIndex)
        let isProfitable = currentValue > investimentAmount
        let gain = currentValue - investimentAmount
        let yield = gain / investimentAmount
        
        return .init(currentValue: currentValue,
                     investimentAmount: investimentAmount,
                     gain: gain,
                     yield: yield,
                     annualReturn: annualReturn,
                     isProfitable: isProfitable)
    }
    
    private func getInvestimentAmount(_ initialInvestimentAmount: Double,
                                      _ monthlyDollarCostAveraging: Double,
                                      _ initialDateOfInvestimentIndex: Int) -> Double {
        
        var totalAmount = Double()
        totalAmount = totalAmount + initialInvestimentAmount
        let dollarCostAveragingAmount = initialDateOfInvestimentIndex.doubleValue * monthlyDollarCostAveraging
        totalAmount = totalAmount + dollarCostAveragingAmount
        
        return totalAmount
    }
    
    private func getCurrentValue(_ numberOfShares: Double, _ latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    private func getLatestSharePrice(_ asset: Asset) -> Double {
        return asset.timeSeriesMonthlyAjusted.getMonthInfos().first?.ajustedClose ?? 0
    }
    
    private func getNumberOfShares(_ asset: Asset,
                                   _ initialInvestimentAmount: Double,
                                   _ monthlyDollarCostAveraging: Double,
                                   _ initialDateOfInvestimentIndex: Int) -> Double {
        
        var totalShares = Double()
        let initialInvestimentOpenPrice = asset.timeSeriesMonthlyAjusted.getMonthInfos()[initialDateOfInvestimentIndex].ajustedOpen
        let initialInvestimentShares = initialInvestimentAmount / initialInvestimentOpenPrice
        totalShares = totalShares + initialInvestimentShares
        asset.timeSeriesMonthlyAjusted.getMonthInfos()
            .prefix(initialDateOfInvestimentIndex)
            .forEach { (monthInfo) in
                let dcaInvestimentShares = monthlyDollarCostAveraging / monthInfo.ajustedOpen
                totalShares = totalShares + dcaInvestimentShares
            }
        
        return totalShares
    }
    
    private func getAnnualReturn(_ currentValue: Double,
                                 _ investimentAmount: Double,
                                 _ initialDateOfInvestimentIndex: Int) -> Double {
        let rate = currentValue / investimentAmount
        let years = ((initialDateOfInvestimentIndex + 1) / 12).doubleValue
        return pow(rate, (1 / years)) - 1
    }
    
}
