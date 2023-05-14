
import XCTest

final class UITestsCurrencyConverter: XCTestCase {
    
    func testAddingCurrencyToMainScreenSuccessfully() {
        let app = XCUIApplication()
        app.launch()
        
        let alert = app.alerts["Make a choice"]
        alert.buttons["OK"].tap()
        XCTAssertTrue(app.tables.cells.staticTexts["USD"].exists)
        XCTAssertTrue(app.tables.cells.staticTexts["EUR"].exists)
        XCTAssertTrue(app.tables.cells.staticTexts["UAH"].exists)
        
        app.buttons["Add Currency"].tap()
        let searchFields = app.searchFields["Search Currency"]
        searchFields.tap()
        searchFields.typeText("Israel")
        app.tables.staticTexts["ILS - Israeli New Sheqel"].tap()
        
        XCTAssertTrue(app.tables.cells.staticTexts["ILS"].exists)
    }
    
    func testRemovingCurrencyFromMainScreenSuccessfully() {
        let app = XCUIApplication()
        app.launch()
        
        let alert = app.alerts["Make a choice"]
        alert.buttons["OK"].tap()
        
        XCTAssertTrue(app.tables.cells.staticTexts["USD"].exists)
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        firstCell.swipeLeft()
        app.tables.buttons["Delete"].tap()
        
        XCTAssertFalse(app.tables.cells.staticTexts["USD"].exists)
        
        XCTAssertTrue(app.tables.cells.staticTexts["EUR"].exists)
        XCTAssertTrue(app.tables.cells.staticTexts["UAH"].exists)
    }
    
    func testUpdateExchangeRateSellSuccessful() {
        let app = XCUIApplication()
        app.launch()
        
        let alert = app.alerts["Make a choice"]
        alert.buttons["OK"].tap()
        
        app.buttons["Sell"].tap()
        let table = app.tables.element
        let cellWithUAH = table.cells.element(boundBy: 2)
        let textField = cellWithUAH.textFields.element
        textField.tap()
        textField.typeText("1000")
        
        let cellUSD = app.tables.cells.containing(.staticText, identifier: "USD").element
        let textFieldInCellWihtUSD = cellUSD.textFields.element
        sleep(2)
        XCTAssertNotEqual(textFieldInCellWihtUSD.value as? String, "0.0")
    }
    
    func testUpdateExchangeRateBuySuccessful() {
        let app = XCUIApplication()
        app.launch()
        
        let alert = app.alerts["Make a choice"]
        alert.buttons["OK"].tap()
        
        app.buttons["Buy"].tap()
        
        let table = app.tables.element
        let firstCell = table.cells.element(boundBy: 0)
        let textField = firstCell.textFields.element
        textField.tap()
        textField.typeText("1000")
        
        let cellEUR = app.tables.cells.containing(.staticText, identifier: "EUR").element
        let textFieldInCellWihtEUR = cellEUR.textFields.element
        sleep(2)
        XCTAssertNotEqual(textFieldInCellWihtEUR.value as? String, "0.0")
    }
    
    func testShareCurrency() {
        let app = XCUIApplication()
        app.launch()
        
        let alert = app.alerts["Make a choice"]
        alert.buttons["OK"].tap()
        
        app.buttons["Share Сurrency"].tap()
        sleep(1)
        XCTAssertTrue(app.navigationBars["UIActivityContentView"].exists)
    }
}
