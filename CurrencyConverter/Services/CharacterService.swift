
import Foundation

protocol CharacterServiceProtocol {
    func isInputOnlyNumbersAndDot(_ string: String) -> Bool
}

final class CharacterService: CharacterServiceProtocol {
    
    func isInputOnlyNumbersAndDot(_ string: String) -> Bool {
        
        let characterSet = CharacterSet(charactersIn: "1234567890.").inverted
        let filteredString = string.components(separatedBy: characterSet).joined()
           return string == filteredString
    }
}
