import UIKit

protocol RepeatingScheduleValueTableViewCellDelegate: DatePickerTableViewCellDelegate {
    func repeatingScheduleValueTableViewCellDidUpdateValue(_ cell: RepeatingScheduleValueTableViewCell)
}

class RepeatingScheduleValueTableViewCell: DatePickerTableViewCell, UITextFieldDelegate {
    weak var delegate: RepeatingScheduleValueTableViewCellDelegate?

    var timeZone: TimeZone! {
        didSet {
            dateFormatter.timeZone = timeZone
            datePicker.timeZone = timeZone
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        return dateFormatter
    }()

    override func updateDateLabel() {
        dateLabel.text = dateFormatter.string(from: date)
    }

    override func dateChanged(_ sender: UIDatePicker) {
        super.dateChanged(sender)

        delegate?.datePickerTableViewCellDidUpdateDate(self)
    }

    var value: Double = 0 {
        didSet {
            textField.text = valueNumberFormatter.string(from: value)
        }
    }

    var datePickerInterval: TimeInterval {
        TimeInterval(minutes: Double(datePicker.minuteInterval))
    }

    var isReadOnly = false {
        didSet {
            if isReadOnly, textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }

    lazy var valueNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1

        return formatter
    }()

    @IBOutlet var dateLabel: UILabel!

    @IBOutlet var unitLabel: UILabel! {
        didSet {
            // Setting this color in code because the nib isn't being applied correctly
            unitLabel.textColor = .secondaryLabel
        }
    }

    @IBOutlet var textField: UITextField! {
        didSet {
            // Setting this color in code because the nib isn't being applied correctly
            textField.textColor = .label
        }
    }

    var unitString: String? {
        get {
            unitLabel.text
        }
        set {
            unitLabel.text = newValue
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_: UITextField) -> Bool {
        !isReadOnly
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        value = valueNumberFormatter.number(from: textField.text ?? "")?.doubleValue ?? 0

        delegate?.repeatingScheduleValueTableViewCellDidUpdateValue(self)
    }
}
