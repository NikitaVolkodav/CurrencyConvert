
import UIKit

protocol TableViewCellServiceProtocol {
    func findMainTableViewCell(for view: UIView) -> MainTableViewCell?
}

final class TableViewCellService: TableViewCellServiceProtocol {
    
    func findMainTableViewCell(for view: UIView) -> MainTableViewCell? {
        var superview = view.superview
        while superview != nil {
            if let cell = superview as? MainTableViewCell {
                return cell
            }
            superview = superview?.superview
        }
        return nil
    }
}
