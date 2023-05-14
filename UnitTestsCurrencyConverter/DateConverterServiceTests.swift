
import XCTest
@testable import CurrencyConverter

final class DateConverterServiceTests: XCTestCase {
    
    var dateConverterService: DateConverterService!
    
    override func setUp() {
        super.setUp()
        dateConverterService = DateConverterService()
    }
    
    override func tearDown() {
        dateConverterService = nil
        super.tearDown()
    }
    
    func testFetchDateSuccessfully() {
        let timestamp = 1683536400
        let dateString = dateConverterService.fetchDate(from: timestamp)
        XCTAssertEqual(dateString, "08 May 2023 12:00 PM", "Date string is incorrect")
    }
}
