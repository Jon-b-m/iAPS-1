import LoopKit
import UIKit

public enum RepeatingScheduleValueResult<T: RawRepresentable> {
    case success(scheduleItems: [RepeatingScheduleValue<T>], timeZone: TimeZone)
    case failure(Error)
}

public protocol SingleValueScheduleTableViewControllerSyncSource: AnyObject {
    func syncScheduleValues(
        for viewController: SingleValueScheduleTableViewController,
        completion: @escaping (_ result: RepeatingScheduleValueResult<Double>) -> Void
    )

    func syncButtonTitle(for viewController: SingleValueScheduleTableViewController) -> String

    func syncButtonDetailText(for viewController: SingleValueScheduleTableViewController) -> String?

    func singleValueScheduleTableViewControllerIsReadOnly(_ viewController: SingleValueScheduleTableViewController) -> Bool
}

open class SingleValueScheduleTableViewController: DailyValueScheduleTableViewController,
    RepeatingScheduleValueTableViewCellDelegate
{
    override open func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            RepeatingScheduleValueTableViewCell.nib(),
            forCellReuseIdentifier: RepeatingScheduleValueTableViewCell.className
        )
        tableView.register(TextButtonTableViewCell.self, forCellReuseIdentifier: TextButtonTableViewCell.className)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if syncSource == nil {
            delegate?.dailyValueScheduleTableViewControllerWillFinishUpdating(self)
        }
    }

    // MARK: - State

    public var scheduleItems: [RepeatingScheduleValue<Double>] = []

    override func addScheduleItem(_ sender: Any?) {
        guard !isReadOnly, !isSyncInProgress else {
            return
        }

        tableView.endEditing(false)

        var startTime = TimeInterval(0)
        var value = 0.0

        if !scheduleItems.isEmpty,
           let cell = tableView
           .cellForRow(at: IndexPath(row: scheduleItems.count - 1, section: 0)) as? RepeatingScheduleValueTableViewCell
        {
            let lastItem = scheduleItems.last!
            let interval = cell.datePickerInterval

            startTime = lastItem.startTime + interval
            value = lastItem.value

            if startTime >= TimeInterval(hours: 24) {
                return
            }
        }

        scheduleItems.append(
            RepeatingScheduleValue(
                startTime: min(TimeInterval(hours: 23.5), startTime),
                value: value
            )
        )

        super.addScheduleItem(sender)
    }

    override func insertableIndiciesByRemovingRow(_ row: Int, withInterval timeInterval: TimeInterval) -> [Bool] {
        insertableIndices(for: scheduleItems, removing: row, with: timeInterval)
    }

    var preferredValueFractionDigits: Int {
        1
    }

    public weak var syncSource: SingleValueScheduleTableViewControllerSyncSource? {
        didSet {
            isReadOnly = syncSource?.singleValueScheduleTableViewControllerIsReadOnly(self) ?? false

            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    private var isSyncInProgress = false {
        didSet {
            for cell in tableView.visibleCells {
                switch cell {
                case let cell as TextButtonTableViewCell:
                    cell.isEnabled = !isSyncInProgress
                    cell.isLoading = isSyncInProgress
                case let cell as RepeatingScheduleValueTableViewCell:
                    cell.isReadOnly = isReadOnly || isSyncInProgress
                default:
                    break
                }
            }

            for item in navigationItem.rightBarButtonItems ?? [] {
                item.isEnabled = !isSyncInProgress
            }

            navigationItem.hidesBackButton = isSyncInProgress
        }
    }

    // MARK: - UITableViewDataSource

    private enum Section: Int {
        case schedule
        case sync
    }

    override open func numberOfSections(in _: UITableView) -> Int {
        if syncSource != nil {
            return 2
        }

        return 1
    }

    override open func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .schedule:
            return scheduleItems.count
        case .sync:
            return 1
        }
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .schedule:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RepeatingScheduleValueTableViewCell.className,
                for: indexPath
            ) as! RepeatingScheduleValueTableViewCell

            let item = scheduleItems[indexPath.row]
            let interval = cell.datePickerInterval

            cell.timeZone = timeZone
            cell.date = midnight.addingTimeInterval(item.startTime)

            cell.valueNumberFormatter.minimumFractionDigits = preferredValueFractionDigits

            cell.value = item.value
            cell.unitString = unitDisplayString
            cell.isReadOnly = isReadOnly || isSyncInProgress
            cell.delegate = self

            if indexPath.row > 0 {
                let lastItem = scheduleItems[indexPath.row - 1]

                cell.datePicker.minimumDate = midnight.addingTimeInterval(lastItem.startTime).addingTimeInterval(interval)
            }

            if indexPath.row < scheduleItems.endIndex - 1 {
                let nextItem = scheduleItems[indexPath.row + 1]

                cell.datePicker.maximumDate = midnight.addingTimeInterval(nextItem.startTime).addingTimeInterval(-interval)
            } else {
                cell.datePicker.maximumDate = midnight.addingTimeInterval(TimeInterval(hours: 24) - interval)
            }

            return cell
        case .sync:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextButtonTableViewCell.className,
                for: indexPath
            ) as! TextButtonTableViewCell

            cell.textLabel?.text = syncSource?.syncButtonTitle(for: self)
            cell.isEnabled = !isSyncInProgress
            cell.isLoading = isSyncInProgress

            return cell
        }
    }

    override open func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .schedule:
            return nil
        case .sync:
            return syncSource?.syncButtonDetailText(for: self)
        }
    }

    override open func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            scheduleItems.remove(at: indexPath.row)

            super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        }
    }

    override open func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        if sourceIndexPath != destinationIndexPath {
            let item = scheduleItems.remove(at: sourceIndexPath.row)
            scheduleItems.insert(item, at: destinationIndexPath.row)

            guard destinationIndexPath.row > 0,
                  let cell = tableView.cellForRow(at: destinationIndexPath) as? RepeatingScheduleValueTableViewCell
            else {
                return
            }

            let interval = cell.datePickerInterval
            let startTime = scheduleItems[destinationIndexPath.row - 1].startTime + interval

            scheduleItems[destinationIndexPath.row] = RepeatingScheduleValue(
                startTime: startTime,
                value: scheduleItems[destinationIndexPath.row].value
            )

            // Since the valid date ranges of neighboring cells are affected, the lazy solution is to just reload the entire table view
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }

    // MARK: - UITableViewDelegate

    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        super.tableView(tableView, canEditRowAt: indexPath) && !isSyncInProgress
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        switch Section(rawValue: indexPath.section)! {
        case .schedule:
            break
        case .sync:
            if let syncSource = syncSource, !isSyncInProgress {
                isSyncInProgress = true
                syncSource.syncScheduleValues(for: self) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(items, timeZone):
                            self.scheduleItems = items
                            self.timeZone = timeZone
                            self.tableView.reloadSections([Section.schedule.rawValue], with: .fade)
                            self.isSyncInProgress = false
                            self.delegate?.dailyValueScheduleTableViewControllerWillFinishUpdating(self)
                        case let .failure(error):
                            self.present(UIAlertController(with: error), animated: true) {
                                self.isSyncInProgress = false
                            }
                        }
                    }
                }
            }
        }
    }

    override open func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {
        guard sourceIndexPath != proposedDestinationIndexPath,
              let cell = tableView.cellForRow(at: sourceIndexPath) as? RepeatingScheduleValueTableViewCell
        else {
            return proposedDestinationIndexPath
        }

        let interval = cell.datePickerInterval
        let indices = insertableIndices(for: scheduleItems, removing: sourceIndexPath.row, with: interval)

        let closestDestinationRow = indices.insertableIndex(
            closestTo: proposedDestinationIndexPath.row,
            from: sourceIndexPath.row
        )
        return IndexPath(row: closestDestinationRow, section: proposedDestinationIndexPath.section)
    }

    // MARK: - RepeatingScheduleValueTableViewCellDelegate

    override public func datePickerTableViewCellDidUpdateDate(_ cell: DatePickerTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let currentItem = scheduleItems[indexPath.row]

            scheduleItems[indexPath.row] = RepeatingScheduleValue(
                startTime: cell.date.timeIntervalSince(midnight),
                value: currentItem.value
            )
        }

        super.datePickerTableViewCellDidUpdateDate(cell)
    }

    func repeatingScheduleValueTableViewCellDidUpdateValue(_ cell: RepeatingScheduleValueTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let currentItem = scheduleItems[indexPath.row]

            scheduleItems[indexPath.row] = RepeatingScheduleValue(startTime: currentItem.startTime, value: cell.value)
        }
    }
}
