
import Foundation

protocol ExchangeRateCacheServiceProtocol {
    func saveExchangeRateDataToCache(_ data: CurrencyData)
    func loadExchangeRateDataFromCache() -> CurrencyData?
}

final class ExchangeRateCacheService: ExchangeRateCacheServiceProtocol {
    
    func saveExchangeRateDataToCache(_ data: CurrencyData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "currencyData")
        }
    }
    
    func loadExchangeRateDataFromCache() -> CurrencyData? {
        if let data = UserDefaults.standard.data(forKey: "currencyData") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(CurrencyData.self, from: data) {
                return decoded
            }
        }
        return nil
    }
    
}
