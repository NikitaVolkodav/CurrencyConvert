
import XCTest
@testable import CurrencyConverter

final class ExchangeRateAPIServiceAndNetworkErrorTests: XCTestCase {
    
    var mockExchangeRateAPIService: MockExchangeRateAPIService!
    
    override func setUp() {
        super.setUp()
        mockExchangeRateAPIService = MockExchangeRateAPIService()
    }
    
    override func tearDown() {
        mockExchangeRateAPIService = nil
        super.tearDown()
    }
    
    func testFetchExchangeRateBaseOnUSDSuccessfully() {
        let expectation = XCTestExpectation(description: "Fetch exchange rate based on USD")
        
        mockExchangeRateAPIService.shouldSucceed = true
        
        mockExchangeRateAPIService.fetchExchangeRateBaseOnUSD { currencyData, error in
            XCTAssertNotNil(currencyData)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testNetworkErrorLocalizedDescriptionSuccessfully() {
        XCTAssertEqual(NetworkError.badStatusCode.localizedDescription, NSLocalizedString("networkError_badStatusCode", comment: ""))
        XCTAssertEqual(NetworkError.badURL.localizedDescription, NSLocalizedString("networkError_badURL", comment: ""))
        XCTAssertEqual(NetworkError.badServerResponse.localizedDescription, NSLocalizedString("networkError_badServerResponse", comment: ""))
        XCTAssertEqual(NetworkError.noDataError.localizedDescription, NSLocalizedString("networkError_noDataError", comment: ""))
    }
}
