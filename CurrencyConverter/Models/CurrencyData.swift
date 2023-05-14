
import Foundation

struct CurrencyData: Codable {
    var timestamp: Int = Int()
    var rates: [String: Double] = [:]
}
