import LoopKit
import UIKit

public protocol DailyValueScheduleTableViewControllerDelegate: AnyObject {
    func dailyValueScheduleTableViewControllerWillFinishUpdating(_ controller: DailyValueScheduleTableViewController)
}

func insertableIndices<T>(
    for scheduleItems: [RepeatingScheduleValue<T>],
    removing row: Int,
    with interval: TimeInterval
) -> [Bool] {
    let insertableIndices = scheduleItems.enumerated().map { (enumeration) -> Bool in
        let (index, item) = enumeration

        if row == index {
            return true
        } else if index == 0 {
            return false
        } else if index == scheduleItems.endIndex - 1 {
            return item.startTime < TimeInterval(hours: 24) - interval
        } else if index > row {
            return scheduleItems[index + 1].startTime - item.startTime > interval
        } else {
            return item.startTime - scheduleItems[index - 1].startTime > interval
        }
    }

    return insertableIndices
}

open class DailyValueScheduleTableViewController: UITableViewController, DatePickerTableViewCellDelegate {
    private var keyboardWillShowNotificationObserver: Any?

    public convenience init() {
        self.init(style: .plain)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

        if !isReadOnly {
            navigationItem.rightBarButtonItems = [insertButtonItem, editButtonItem]
        }

        tableView.keyboardDismissMode = .onDrag

        keyboardWillShowNotificationObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] (note) -> Void in
                guard let strongSelf = self else {
                    return
                }

                guard note.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool == true else {
                    return
                }

                let animated = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0 > 0

                if let indexPath = strongSelf.tableView.indexPathForSelectedRow {
                    strongSelf.tableView.beginUpdates()
                    strongSelf.tableView.deselectRow(at: indexPath, animated: animated)
                    strongSelf.tableView.endUpdates()
                }
            }
        )
    }

    override open func setEditing(_ editing: Bool, animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.beginUpdates()
            tableView.deselectRow(at: indexPath, animated: animated)
            tableView.endUpdates()
        }

        tableView.endEditing(false)

        navigationItem.rightBarButtonItems?[0].isEnabled = !editing

        super.setEditing(editing, animated: animated)
    }

    deinit {
        if let observer = keyboardWillShowNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tableView.endEditing(true)
    }

    public weak var delegate: DailyValueScheduleTableViewControllerDelegate?

    public private(set) lazy var insertButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScheduleItem(_:)))
    }()

    // MARK: - State

    public var timeZone = TimeZone.currentFixed {
        didSet {
            calendar.timeZone = timeZone

            let localTimeZone = TimeZone.current
            let timeZoneDiff = TimeInterval(timeZone.secondsFromGMT() - localTimeZone.secondsFromGMT())

            if timeZoneDiff != 0 {
                let localTimeZoneName = localTimeZone.abbreviation() ?? localTimeZone.identifier
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                let diffString = formatter.string(from: abs(timeZoneDiff)) ?? String(abs(timeZoneDiff))

                navigationItem.prompt = String(
                    format: LocalizedString(
                        "Times in %1$@%2$@%3$@",
                        comment: "The schedule table view header describing the configured time zone difference from the default time zone. The substitution parameters are: (1: time zone name)(2: +/-)(3: time interval)"
                    ),
                    localTimeZoneName, timeZoneDiff < 0 ? "-" : "+", diffString
                )
            }
        }
    }

    public var unitDisplayString: String = "U/hour"

    public var isReadOnly: Bool = false {
        didSet {
            if isReadOnly {
                isEditing = false
            }

            if isViewLoaded {
                navigationItem.setRightBarButtonItems(isReadOnly ? [] : [insertButtonItem, editButtonItem], animated: true)
            }
        }
    }

    private var calendar = Calendar.current

    var midnight: Date {
        calendar.startOfDay(for: Date())
    }

    @objc func addScheduleItem(_: Any?) {
        guard !isReadOnly else {
            return
        }
        // Updates the table view state. Subclasses should update their data model before calling super

        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
    }

    func insertableIndiciesByRemovingRow(_: Int, withInterval _: TimeInterval) -> [Bool] {
        fatalError("Subclasses must override \(#function)")
    }

    // MARK: - UITableViewDataSource

    override open func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override open func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        fatalError("Subclasses must override \(#function)")
    }

    override open func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        !isReadOnly && indexPath.section == 0 && indexPath.row > 0
    }

    override open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        self.tableView(tableView, canEditRowAt: indexPath)
    }

    override open func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        fatalError("Subclasses must override \(#function)")
    }

    override open func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            // Updates the table view state. Subclasses should update their data model before calling super

            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - UITableViewDelegate

    override open func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 else {
            return true
        }

        return !isReadOnly && indexPath.row > 0
    }

    override open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard self.tableView(tableView, shouldHighlightRowAt: indexPath) else {
            return nil
        }

        tableView.endEditing(false)
        tableView.beginUpdates()
        hideDatePickerCells(excluding: indexPath)
        return indexPath
    }

    override open func tableView(_ tableView: UITableView, didDeselectRowAt _: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(false)
        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override open func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {
        guard sourceIndexPath.section == proposedDestinationIndexPath.section else {
            return sourceIndexPath
        }

        guard sourceIndexPath != proposedDestinationIndexPath,
              let cell = tableView.cellForRow(at: sourceIndexPath) as? RepeatingScheduleValueTableViewCell
        else {
            return proposedDestinationIndexPath
        }

        let interval = cell.datePickerInterval
        let indices = insertableIndiciesByRemovingRow(sourceIndexPath.row, withInterval: interval)

        let closestDestinationRow = indices.insertableIndex(
            closestTo: proposedDestinationIndexPath.row,
            from: sourceIndexPath.row
        )
        return IndexPath(row: closestDestinationRow, section: proposedDestinationIndexPath.section)
    }

    // MARK: - DatePickerTableViewCellDelegate

    public func datePickerTableViewCellDidUpdateDate(_ cell: DatePickerTableViewCell) {
        // Updates the TableView state. Subclasses should update their data model
        if let indexPath = tableView.indexPath(for: cell) {
            var indexPaths: [IndexPath] = []

            if indexPath.row > 0 {
                indexPaths.append(IndexPath(row: indexPath.row - 1, section: indexPath.section))
            }

            if indexPath.row < tableView.numberOfRows(inSection: 0) - 1 {
                indexPaths.append(IndexPath(row: indexPath.row + 1, section: indexPath.section))
            }

            DispatchQueue.main.async {
                self.tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
    }
}

extension Array where Element == Bool {
    func insertableIndex(closestTo destination: Int, from source: Int) -> Int {
        if self[destination] {
            return destination
        } else {
            var closestRow = source
            for (index, valid) in enumerated() where valid {
                if abs(destination - index) < abs(destination - closestRow) {
                    closestRow = index
                }
            }
            return closestRow
        }
    }
}
