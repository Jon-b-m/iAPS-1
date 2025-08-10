import UIKit

public protocol DateAndDurationTableViewControllerDelegate: AnyObject {
    func dateAndDurationTableViewControllerDidChangeDate(_ controller: DateAndDurationTableViewController)
}

public class DateAndDurationTableViewController: UITableViewController {
    public enum InputMode {
        case date(Date, mode: UIDatePicker.Mode)
        case duration(TimeInterval)
    }

    public var inputMode: InputMode = .date(Date(), mode: .dateAndTime) {
        didSet {
            delegate?.dateAndDurationTableViewControllerDidChangeDate(self)
        }
    }

    public var titleText: String?

    public var contextHelp: String?

    public var indexPath: IndexPath?

    public weak var delegate: DateAndDurationTableViewControllerDelegate?

    public convenience init() {
        self.init(style: .grouped)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(DateAndDurationTableViewCell.nib(), forCellReuseIdentifier: DateAndDurationTableViewCell.className)
    }

    private var completion: ((InputMode) -> Void)?

    public func onSave(_ completion: @escaping (InputMode) -> Void) {
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        self.completion = completion
    }

    @objc private func save() {
        completion?(inputMode)
        dismiss(animated: true)
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DateAndDurationTableViewCell.className,
            for: indexPath
        ) as! DateAndDurationTableViewCell
        switch inputMode {
        case let .date(date, mode: mode):
            cell.datePicker.datePickerMode = mode
            cell.date = date
        case let .duration(duration):
            cell.datePicker.datePickerMode = .countDownTimer
            cell.maximumDuration = .hours(24)
            cell.duration = duration
        }
        cell.titleLabel.text = titleText
        cell.isDatePickerHidden = false
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    override public func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        contextHelp
    }
}

extension DateAndDurationTableViewController: DatePickerTableViewCellDelegate {
    public func datePickerTableViewCellDidUpdateDate(_ cell: DatePickerTableViewCell) {
        switch inputMode {
        case let .date(_, mode: mode):
            inputMode = .date(cell.date, mode: mode)
        case .duration:
            inputMode = .duration(cell.duration)
        }
    }
}
