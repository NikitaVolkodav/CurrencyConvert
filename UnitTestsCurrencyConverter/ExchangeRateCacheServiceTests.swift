
import XCTest
@testable import CurrencyConverter

final class ExchangeRateCacheServiceTests: XCTestCase {
    
    var exchangeRateCacheService: ExchangeRateCacheService!
    
    override func setUp() {
        super.setUp()
        exchangeRateCacheService = ExchangeRateCacheService()
        UserDefaults.standard.removeObject(forKey: "currencyData")
    }
    
    override func tearDown() {
        exchangeRateCacheService = nil
        super.tearDown()
    }
    
    func testSaveAndLoadExchangeRateDataSuccessfully() {
        let data = CurrencyData(timestamp: 1620488573, rates: ["EUR": 0.82542, "GBP": 0.71459])
        
        exchangeRateCacheService.saveExchangeRateDataToCache(data)
        
        let loadedData = exchangeRateCacheService.loadExchangeRateDataFromCache()
        
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData?.timestamp, data.timestamp)
        XCTAssertEqual(loadedData?.rates, data.rates)
    }
    
    func testLoadExchangeRateDataFromEmptyCacheSuccessfully() {
        let loadedData = exchangeRateCacheService.loadExchangeRateDataFromCache()
        XCTAssertNil(loadedData)
    }
    
    func testLoadExchangeRateDataFromInvalidCacheSuccessfully() {
        let invalidData = Data("invalid data".utf8)
        UserDefaults.standard.set(invalidData, forKey: "currencyData")
        let loadedData = exchangeRateCacheService.loadExchangeRateDataFromCache()
        
        XCTAssertNil(loadedData)
    }
}
