import UIKit

public protocol PercentageTextFieldTableViewControllerDelegate: AnyObject {
    func percentageTextFieldTableViewControllerDidChangePercentage(_ controller: PercentageTextFieldTableViewController)
}

public class PercentageTextFieldTableViewController: TextFieldTableViewController {
    public var percentage: Double? {
        get {
            if let doubleValue = value.flatMap(Double.init) {
                return doubleValue / 100
            } else {
                return nil
            }
        }
        set {
            if let percentage = newValue {
                value = percentageFormatter.string(from: percentage * 100)
            } else {
                value = nil
            }
        }
    }

    public weak var percentageDelegate: PercentageTextFieldTableViewControllerDelegate?

    var maximumFractionDigits: Int = 1 {
        didSet {
            percentageFormatter.maximumFractionDigits = maximumFractionDigits
        }
    }

    private lazy var percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }()

    public convenience init() {
        self.init(style: .grouped)
        unit = "%"
        keyboardType = .decimalPad
        placeholder = "Enter percentage"
        delegate = self
    }
}

extension PercentageTextFieldTableViewController: TextFieldTableViewControllerDelegate {
    public func textFieldTableViewControllerDidEndEditing(_: TextFieldTableViewController) {
        percentageDelegate?.percentageTextFieldTableViewControllerDidChangePercentage(self)
    }

    public func textFieldTableViewControllerDidReturn(_: TextFieldTableViewController) {
        percentageDelegate?.percentageTextFieldTableViewControllerDidChangePercentage(self)
    }
}
