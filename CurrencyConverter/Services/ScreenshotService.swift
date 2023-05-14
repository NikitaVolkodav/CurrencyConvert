
import UIKit
import Foundation

protocol ScreenshotServiceProtocol {
    func takeScreenshot(of view: UIView) -> UIImage
}

final class ScreenshotService: ScreenshotServiceProtocol {
    
     func takeScreenshot(of view: UIView) -> UIImage {
             UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
             defer { UIGraphicsEndImageContext() }
             view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
             let screenshot = UIGraphicsGetImageFromCurrentImageContext()
         
        return screenshot ?? UIImage()
    }
}
