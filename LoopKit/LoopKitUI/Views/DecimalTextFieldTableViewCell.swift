import UIKit

public class DecimalTextFieldTableViewCell: TextFieldTableViewCell {
    @IBOutlet var titleLabel: UILabel!

    var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        return formatter
    }()

    public var number: NSNumber? {
        get {
            numberFormatter.number(from: textField.text ?? "")
        }
        set {
            if let value = newValue {
                textField.text = numberFormatter.string(from: value)
            } else {
                textField.text = nil
            }
        }
    }

    // MARK: - UITextFieldDelegate

    override public func textFieldDidEndEditing(_ textField: UITextField) {
        if let number = number {
            textField.text = numberFormatter.string(from: number)
        } else {
            textField.text = nil
        }

        super.textFieldDidEndEditing(textField)
    }
}
