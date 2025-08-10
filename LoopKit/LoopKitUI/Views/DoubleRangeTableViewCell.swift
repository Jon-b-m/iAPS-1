import LoopKit
import UIKit

protocol DoubleRangeTableViewCellDelegate: AnyObject {
    func doubleRangeTableViewCellDidBeginEditing(_ cell: DoubleRangeTableViewCell)
    func doubleRangeTableViewCellDidUpdateRange(_ cell: DoubleRangeTableViewCell)
}

class DoubleRangeTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var minValueTextField: PaddedTextField! {
        didSet {
            minValueTextField.delegate = self
            minValueTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        }
    }

    @IBOutlet var maxValueTextField: PaddedTextField! {
        didSet {
            maxValueTextField.delegate = self
            maxValueTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        }
    }

    @IBOutlet var unitLabel: UILabel!

    var numberFormatter = NumberFormatter()

    var range: DoubleRange? {
        get {
            guard
                let minValueString = minValueTextField.text,
                let minValue = numberFormatter.number(from: minValueString)?.doubleValue,
                let maxValueString = maxValueTextField.text,
                let maxValue = numberFormatter.number(from: maxValueString)?.doubleValue
            else {
                return nil
            }

            return DoubleRange(minValue: minValue, maxValue: maxValue)
        }
        set {
            guard let newValue = newValue else {
                minValueTextField.text = nil
                maxValueTextField.text = nil
                return
            }
            minValueTextField.text = numberFormatter.string(from: newValue.minValue)
            maxValueTextField.text = numberFormatter.string(from: newValue.maxValue)
        }
    }

    weak var delegate: DoubleRangeTableViewCellDelegate?

    @objc private func textFieldEditingChanged() {
        delegate?.doubleRangeTableViewCellDidUpdateRange(self)
    }
}

extension DoubleRangeTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        delegate?.doubleRangeTableViewCellDidBeginEditing(self)
    }

    func textFieldDidEndEditing(_: UITextField) {
        delegate?.doubleRangeTableViewCellDidUpdateRange(self)
    }
}
