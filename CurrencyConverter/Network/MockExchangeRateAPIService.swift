
import Foundation

final class MockExchangeRateAPIService: ExchangeRateAPIServiceProtocol {
    
    var shouldSucceed = true
    
    func fetchExchangeRateBaseOnUSD(_ completion: @escaping (CurrencyData?, NetworkError?) -> Void) {
        if shouldSucceed {
            let data = """
                    {"timestamp":1683709200,"rates":{"ILS":3.66775,"USD":1.0,"UAH":36.960803,"EUR":0.91308}}
                """.data(using: .utf8)!
            
            do {
                let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                completion(currencyData, nil)
            } catch {
                completion(nil, NetworkError.badStatusCode)
            }
        } else {
            completion(nil, NetworkError.badServerResponse)
        }
    }
}
