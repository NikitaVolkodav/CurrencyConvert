
import Foundation

protocol ExchangeRateAPIServiceProtocol {
    func fetchExchangeRateBaseOnUSD(_ completion: @escaping (CurrencyData?, NetworkError?) -> Void)
}

final class ExchangeRateAPIService: ExchangeRateAPIServiceProtocol  {
        
    private var urlComponents: URLComponents {
        let apiKey = "3ce1e465e1234e48a9199b5922b58ac8"
        var components = URLComponents()
        components.scheme = "https"
            components.host = "openexchangerates.org"
            components.path = "/api/latest.json"
        components.queryItems = [ URLQueryItem(name: "app_id", value: apiKey) ]
        return components
    }
        
    func fetchExchangeRateBaseOnUSD(_ completion: @escaping (CurrencyData?, NetworkError?) -> Void) {
        
        guard let url = urlComponents.url else {
            completion(nil, NetworkError.badURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil,
                  let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkError.noDataError)
                return
            }
            if httpResponse.statusCode == 200 {
                do {
                    let parsingData = try JSONDecoder().decode(CurrencyData.self, from: data)
                    completion(parsingData, nil)
                } catch {
                    completion(nil, NetworkError.badServerResponse)
                }
            } else {
                completion(nil, NetworkError.badStatusCode)
            }
        }
        .resume()
    }    
}
