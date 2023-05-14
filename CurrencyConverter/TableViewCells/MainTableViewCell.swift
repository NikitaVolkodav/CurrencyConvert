
import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyTitleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var delegate: UITextFieldDelegate?
        
}
