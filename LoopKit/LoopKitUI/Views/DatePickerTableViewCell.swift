import UIKit

public protocol DatePickerTableViewCellDelegate: AnyObject {
    func datePickerTableViewCellDidUpdateDate(_ cell: DatePickerTableViewCell)
}

open class DatePickerTableViewCell: UITableViewCell {
    open var date: Date {
        get {
            datePicker.date
        }
        set {
            if let maximumDate = datePicker.maximumDate,
               newValue >= maximumDate
            {
                datePicker.setDate(maximumDate, animated: true)
            } else if let minimumDate = datePicker.minimumDate,
                      newValue <= minimumDate
            {
                datePicker.setDate(minimumDate, animated: true)
            } else {
                datePicker.setDate(newValue, animated: true)
            }
            dateChanged(datePicker)
            updateDateLabel()
        }
    }

    open var duration: TimeInterval {
        get {
            datePicker.countDownDuration
        }
        set {
            datePicker.countDownDuration = newValue
            updateDateLabel()
        }
    }

    open var maximumDuration = TimeInterval(hours: 8) {
        didSet {
            if duration > maximumDuration {
                duration = maximumDuration
            }
        }
    }

    @IBOutlet open var datePicker: UIDatePicker!

    @IBOutlet open var datePickerHeightConstraint: NSLayoutConstraint!

    private var datePickerExpandedHeight: CGFloat = 0

    open var isDatePickerHidden: Bool {
        get {
            datePicker.isHidden || !datePicker.isEnabled
        }
        set {
            if datePicker.isEnabled {
                datePicker.isHidden = newValue
                datePickerHeightConstraint.constant = newValue ? 0 : datePickerExpandedHeight

                if !newValue, case .countDownTimer = datePicker.datePickerMode {
                    // Workaround for target-action change notifications not firing if initial value is set while view is hidden
                    DispatchQueue.main.async {
                        self.datePicker.date = self.datePicker.date
                        self.datePicker.countDownDuration = self.datePicker.countDownDuration
                    }
                }
            }
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        datePickerExpandedHeight = datePickerHeightConstraint.constant

        setSelected(true, animated: false)
        updateDateLabel()
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            isDatePickerHidden = !isDatePickerHidden
        }
    }

    open func updateDateLabel() {}

    @IBAction open func dateChanged(_ sender: UIDatePicker) {
        if case .countDownTimer = sender.datePickerMode, duration > maximumDuration {
            duration = maximumDuration
        } else {
            updateDateLabel()
        }
    }
}

/// UITableViewController extensions to aid working with DatePickerTableViewCell
public extension DatePickerTableViewCellDelegate where Self: UITableViewController {
    func hideDatePickerCells(excluding indexPath: IndexPath? = nil) {
        guard isViewLoaded else {
            return
        }
        for case let cell as DatePickerTableViewCell in tableView.visibleCells
            where tableView.indexPath(for: cell) != indexPath && cell.isDatePickerHidden == false
        {
            cell.isDatePickerHidden = true
        }
    }
}
