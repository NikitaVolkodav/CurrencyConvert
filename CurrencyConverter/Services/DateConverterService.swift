
import Foundation

protocol DateConverterServiceProtocol {
    func fetchDate(from timestamp: Int) -> String
}

final class DateConverterService: DateConverterServiceProtocol {
    
     func fetchDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy h:mm a"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}
