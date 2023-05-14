
import XCTest
@testable import CurrencyConverter

final class CharacterServiceTests: XCTestCase {
    
    var characterService: CharacterService!
    
    override func setUp() {
        super.setUp()
        characterService = CharacterService()
        UserDefaults.standard.removeObject(forKey: "currencyData")
    }
    
    override func tearDown() {
        characterService = nil
        super.tearDown()
    }
    
    func testCharacterServiceWhereInputOnlyNumbersSuccessfully() {
        XCTAssertTrue(characterService.isInputOnlyNumbersAndDot("1234"))
        XCTAssertTrue(characterService.isInputOnlyNumbersAndDot("1.23"))
        XCTAssertTrue(characterService.isInputOnlyNumbersAndDot("0.4"))
        XCTAssertTrue(characterService.isInputOnlyNumbersAndDot(".567"))
    }
    
    func testCharacterServiceWhereInputOnlyNumbersNotSuccessfully() {
        XCTAssertFalse(characterService.isInputOnlyNumbersAndDot("1234a"))
        XCTAssertFalse(characterService.isInputOnlyNumbersAndDot("1.2.3?"))
        XCTAssertFalse(characterService.isInputOnlyNumbersAndDot("-0.4"))
        XCTAssertFalse(characterService.isInputOnlyNumbersAndDot("1..23="))
    }
}
