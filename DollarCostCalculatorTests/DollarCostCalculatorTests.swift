//
//  DollarCostCalculatorTests.swift
//  DollarCostCalculatorTests
//
//  Created by Brendon Bitencourt Braga on 2021-04-23.
//

import XCTest
@testable import DollarCostCalculator

class DollarCostCalculatorTests: XCTestCase {
    
    var sut: DCAService?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.sut = DCAService()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.sut = nil
    }
    
    // What + Given + Expectation (Use to create yours name func)
    func _testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Given + When + Then (Use to create yours func)
    }
    
    // 1 Test Case - Assets = Winning | DCA = true => Positive Gains
    func testDCAResult_givenWinningAssetsAndDCAIsUsed_expectPositiveGains() throws {
        // Given
        let assetMocked = buildMockedWinningAsset()
        let initialInvestimentAmountFixed: Double = 5000
        let monthlyDollarCostAveragingFixed: Double = 1500
        let initialDateOfInvestimentIndexFixed: Int = 5
        // When
        let result = sut?.calculate(asset: assetMocked,
                                    initialInvestimentAmount: initialInvestimentAmountFixed,
                                    monthlyDollarCostAveraging: monthlyDollarCostAveragingFixed,
                                    initialDateOfInvestimentIndex: initialDateOfInvestimentIndexFixed)
        // Then
        /**
         Calculate - Investiment Amount
         Initial investiment = $5000
         DCA = $1500 * 5 = $7500
         Total = $5000 + $7500
         */
        let investimentAmount = try XCTUnwrap(result?.investimentAmount)
        XCTAssertEqual(investimentAmount, 12500)
        
        /**
         Calculate - Current Value
         Jan - $5000 / 100 = 50 shares
         Feb - $1500 / 110 = 13.6363 shares
         Mar - $1500 / 120 = 12.5 shares
         Abr - $1500 / 130 = 11.5384 shares
         May - $1500 / 140 = 10.7142 shares
         Jun - $1500 / 150 = 10 shares
         Total Shares = 108.3889
         Total Current Value = 108.3889 * 160 (Lastest month closing prive) = $17342.224
         */
        let currentValue = try XCTUnwrap(result?.currentValue)
        XCTAssertEqual(currentValue, 17342.224, accuracy: 0.1)
        
        /**
         Calculate - Gain Value
         Gain = Current value - Initial Amount
         Total = $17342.224 - $12500 = $4842.224
         */
        let gain = try XCTUnwrap(result?.gain)
        XCTAssertEqual(gain, 4842.224, accuracy: 0.1)
        
        /**
         Calculate - Yield Value
         Yield = Gain - Initial Amount
         Total = $4842.224 / $12500 = 0.3873
         */
        let yield = try XCTUnwrap(result?.yield)
        XCTAssertEqual(yield, 0.3873, accuracy: 0.0001)
    }
    
    // 2 Test Case - Assets = Winning | DCA = false => Positive Gains
    func testDCAResult_givenWinningAssetsAndDCAIsNotUsed_expectPositiveGains() throws {
        // Given
        // When
        // Then
    }
    
    // 3 Test Case - Assets = Losing | DCA = true => Negative Gains
    func testDCAResult_givenLosingAssetsAndDCAIsUsed_expectNegativeGains() throws {
        // Given
        // When
        // Then
        
    }
    
    // 4  Test Case - Assets = Losing | DCA = false => Positive Gains
    func testDCAResult_givenLosingAssetsAndDCAIsNotUsed_expectNegativeGains() throws {
        // Given
        // When
        // Then
    }
    
    private func buildMockedWinningAsset() -> Asset {
        let searchResultMocked = getMockedSearchResult()
        let metaMocked = getMockedMeta()
        let timeSeriesMocked: [String : OHLC] = ["2021-01-20":OHLC(open: "100", close: "110", ajustedClose: "110"),
                                                 "2021-02-20":OHLC(open: "110", close: "120", ajustedClose: "120"),
                                                 "2021-03-20":OHLC(open: "120", close: "130", ajustedClose: "130"),
                                                 "2021-04-20":OHLC(open: "130", close: "140", ajustedClose: "140"),
                                                 "2021-05-20":OHLC(open: "140", close: "150", ajustedClose: "150"),
                                                 "2021-06-20":OHLC(open: "150", close: "160", ajustedClose: "160")]
        let timeSeriesMonthlyAjusted = TimeSeriesMonthlyAjusted(meta: metaMocked, timeSeries: timeSeriesMocked)
        let asset = Asset(searchResult: searchResultMocked, timeSeriesMonthlyAjusted: timeSeriesMonthlyAjusted)
        return asset
    }
    
    private func getMockedSearchResult() -> SearchResult {
        let searchResult = SearchResult(symbol: "XYZ", name: "XYZ Company", type: "ETF", currency: "USD")
        return searchResult
    }
    
    private func getMockedMeta() -> Meta {
        let meta = Meta(symbol: "XYZ")
        return meta
    }
    
    //MARK: - Only for Education
    func testInvestimentAmount_whenDollarCostAveragingIsUsed_expectResult() {
        // Given
        let initialInvestimentAmount: Double = 500
        let monthlyDollarCostAveraging: Double = 300
        let initialDateOfInvestimentIndex: Int = 4 // (5 Months ago)
        // When
        let result = sut?.getInvestimentAmount(initialInvestimentAmount, monthlyDollarCostAveraging, initialDateOfInvestimentIndex)
        // Then
        XCTAssertEqual(result, 1700)
        
        /**
        Calculate
         Initial Amount = $500
         DCA = 4 * $300 = $1200
         Total = $1200 + $500 = $1700
         */
    }
    
    func testInvestimentAmount_whenDollarCostAveragingIsNotUsed_expectResult() {
        // Given
        let initialInvestimentAmount: Double = 500
        let monthlyDollarCostAveraging: Double = 0
        let initialDateOfInvestimentIndex: Int = 4 // (5 Months ago)
        // When
        let result = sut?.getInvestimentAmount(initialInvestimentAmount, monthlyDollarCostAveraging, initialDateOfInvestimentIndex)
        // Then
        XCTAssertEqual(result, 500)
        
        /**
         Calculate
          Initial Amount = $500
          DCA = 4 * $0 = $0
          Total = $0 + $500 = $500
         */
    }
    
}
