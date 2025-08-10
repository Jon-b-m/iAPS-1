import UIKit

public class LabeledTextFieldTableViewCell: TextFieldTableViewCell {
    @IBOutlet public var titleLabel: UILabel!

    private var customInputTextField: CustomInputTextField? {
        textField as? CustomInputTextField
    }

    public var customInput: UIInputViewController? {
        get {
            customInputTextField?.customInput
        }
        set {
            customInputTextField?.customInput = newValue
        }
    }
}
