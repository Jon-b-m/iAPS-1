//
//  LegacyInsulinDeliveryTableViewController.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 1/30/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//
import LoopKit
import UIKit

private let ReuseIdentifier = "Right Detail"

public final class LegacyInsulinDeliveryTableViewController: UITableViewController {
    @IBOutlet var needsConfigurationMessageView: ErrorBackgroundView!

    @IBOutlet var iobValueLabel: UILabel! {
        didSet {
            iobValueLabel.textColor = headerValueLabelColor
        }
    }

    @IBOutlet var iobDateLabel: UILabel!

    @IBOutlet var totalValueLabel: UILabel! {
        didSet {
            totalValueLabel.textColor = headerValueLabelColor
        }
    }

    @IBOutlet var totalDateLabel: UILabel!

    @IBOutlet var dataSourceSegmentedControl: UISegmentedControl! {
        didSet {
            let titleFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
            dataSourceSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: titleFont], for: .normal)
            dataSourceSegmentedControl.setTitle(
                LocalizedString("Event History", comment: "Segmented button title for insulin delivery log event history"),
                forSegmentAt: 0
            )
            dataSourceSegmentedControl.setTitle(
                LocalizedString("Reservoir", comment: "Segmented button title for insulin delivery log reservoir history"),
                forSegmentAt: 1
            )
        }
    }

    public var enableEntryDeletion: Bool = true

    public var doseStore: DoseStore? {
        didSet {
            if let doseStore = doseStore {
                doseStoreObserver = NotificationCenter.default.addObserver(
                    forName: nil,
                    object: doseStore,
                    queue: OperationQueue.main,
                    using: { [weak self] (note) -> Void in

                        switch note.name {
                        case DoseStore.valuesDidChange:
                            if self?.isViewLoaded == true {
                                self?.reloadData()
                            }
                        default:
                            break
                        }
                    }
                )
            } else {
                doseStoreObserver = nil
            }
        }
    }

    public var headerValueLabelColor: UIColor = .label

    private var updateTimer: Timer? {
        willSet {
            if let timer = updateTimer {
                timer.invalidate()
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        state = .display
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateTimelyStats(nil)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let updateInterval = TimeInterval(minutes: 5)
        let timer = Timer(
            fireAt: Date().dateCeiledToTimeInterval(updateInterval).addingTimeInterval(2),
            interval: updateInterval,
            target: self,
            selector: #selector(updateTimelyStats(_:)),
            userInfo: nil,
            repeats: true
        )
        updateTimer = timer

        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        updateTimer = nil
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if tableView.isEditing {
            tableView.endEditing(true)
        }
    }

    deinit {
        if let observer = doseStoreObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override public func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing, enableEntryDeletion {
            let item = UIBarButtonItem(
                title: LocalizedString("Delete All", comment: "Button title to delete all objects"),
                style: .plain,
                target: self,
                action: #selector(confirmDeletion(_:))
            )
            navigationItem.setLeftBarButton(item, animated: true)
        } else {
            navigationItem.setLeftBarButton(nil, animated: true)
        }
    }

    // MARK: - Data

    private enum State {
        case unknown
        case unavailable(Error?)
        case display
    }

    private var state = State.unknown {
        didSet {
            if isViewLoaded {
                reloadData()
            }
        }
    }

    private enum DataSourceSegment: Int {
        case history = 0
        case reservoir
    }

    private enum Values {
        case reservoir([ReservoirValue])
        case history([PersistedPumpEvent])
    }

    // Not thread-safe
    private var values = Values.reservoir([]) {
        didSet {
            let count: Int

            switch values {
            case let .reservoir(values):
                count = values.count
            case let .history(values):
                count = values.count
            }

            if count > 0, enableEntryDeletion {
                navigationItem.rightBarButtonItem = editButtonItem
            }
        }
    }

    private func reloadData() {
        switch state {
        case .unknown:
            break
        case let .unavailable(error):
            tableView.tableHeaderView?.isHidden = true
            tableView.tableFooterView = UIView()
            tableView.backgroundView = needsConfigurationMessageView

            if let error = error {
                needsConfigurationMessageView.errorDescriptionLabel.text = String(describing: error)
            } else {
                needsConfigurationMessageView.errorDescriptionLabel.text = nil
            }
        case .display:
            tableView.backgroundView = nil
            tableView.tableHeaderView?.isHidden = false
            tableView.tableFooterView = nil

            switch DataSourceSegment(rawValue: dataSourceSegmentedControl.selectedSegmentIndex)! {
            case .reservoir:
                doseStore?.getReservoirValues(since: Date.distantPast) { result in
                    DispatchQueue.main.async { () -> Void in
                        switch result {
                        case let .failure(error):
                            self.state = .unavailable(error)
                        case let .success(reservoirValues):
                            self.values = .reservoir(reservoirValues)
                            self.tableView.reloadData()
                        }
                    }

                    self.updateTimelyStats(nil)
                    self.updateTotal()
                }
            case .history:
                doseStore?.getPumpEventValues(since: Date.distantPast) { result in
                    DispatchQueue.main.async { () -> Void in
                        switch result {
                        case let .failure(error):
                            self.state = .unavailable(error)
                        case let .success(pumpEventValues):
                            self.values = .history(pumpEventValues)
                            self.tableView.reloadData()
                        }
                    }

                    self.updateTimelyStats(nil)
                    self.updateTotal()
                }
            }
        }
    }

    @objc func updateTimelyStats(_: Timer?) {
        updateIOB()
    }

    private lazy var iobNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        return formatter
    }()

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()

    private func updateIOB() {
        if case .display = state {
            doseStore?.insulinOnBoard(at: Date()) { (result) -> Void in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.iobValueLabel.text = "…"
                        self.iobDateLabel.text = nil
                    case let .success(iob):
                        self.iobValueLabel.text = self.iobNumberFormatter.string(from: iob.value)
                        self.iobDateLabel.text = String(
                            format: LocalizedString(
                                "com.loudnate.InsulinKit.IOBDateLabel",
                                value: "at %1$@",
                                comment: "The format string describing the date of an IOB value. The first format argument is the localized date."
                            ),
                            self.timeFormatter.string(from: iob.startDate)
                        )
                    }
                }
            }
        }
    }

    private func updateTotal() {
        if case .display = state {
            let midnight = Calendar.current.startOfDay(for: Date())

            doseStore?.getTotalUnitsDelivered(since: midnight) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.totalValueLabel.text = "…"
                        self.totalDateLabel.text = nil
                    case let .success(result):
                        self.totalValueLabel.text = NumberFormatter.localizedString(
                            from: NSNumber(value: result.value),
                            number: .none
                        )
                        self.totalDateLabel.text = String(
                            format: LocalizedString(
                                "com.loudnate.InsulinKit.totalDateLabel",
                                value: "since %1$@",
                                comment: "The format string describing the starting date of a total value. The first format argument is the localized date."
                            ),
                            DateFormatter.localizedString(from: result.startDate, dateStyle: .none, timeStyle: .short)
                        )
                    }
                }
            }
        }
    }

    private var doseStoreObserver: Any? {
        willSet {
            if let observer = doseStoreObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }

    @IBAction func selectedSegmentChanged(_: Any) {
        reloadData()
    }

    @IBAction func confirmDeletion(_: Any) {
        guard !deletionPending else {
            return
        }

        let confirmMessage: String

        switch DataSourceSegment(rawValue: dataSourceSegmentedControl.selectedSegmentIndex)! {
        case .reservoir:
            confirmMessage = LocalizedString(
                "Are you sure you want to delete all reservoir values?",
                comment: "Action sheet confirmation message for reservoir deletion"
            )
        case .history:
            confirmMessage = LocalizedString(
                "Are you sure you want to delete all history entries?",
                comment: "Action sheet confirmation message for pump history deletion"
            )
        }

        let sheet = UIAlertController(deleteAllConfirmationMessage: confirmMessage) {
            self.deleteAllObjects()
        }
        present(sheet, animated: true)
    }

    private var deletionPending = false

    private func deleteAllObjects() {
        guard !deletionPending else {
            return
        }

        deletionPending = true

        let completion = { (_: DoseStore.DoseStoreError?) -> Void in
            DispatchQueue.main.async {
                self.deletionPending = false
                self.setEditing(false, animated: true)
            }
        }

        switch DataSourceSegment(rawValue: dataSourceSegmentedControl.selectedSegmentIndex)! {
        case .reservoir:
            doseStore?.deleteAllReservoirValues(completion)
        case .history:
            doseStore?.deleteAllPumpEvents(completion)
        }
    }

    // MARK: - Table view data source

    override public func numberOfSections(in _: UITableView) -> Int {
        switch state {
        case .unavailable,
             .unknown:
            return 0
        case .display:
            return 1
        }
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch values {
        case let .reservoir(values):
            return values.count
        case let .history(values):
            return values.count
        }
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier, for: indexPath)

        if case .display = state {
            switch self.values {
            case let .reservoir(values):
                let entry = values[indexPath.row]
                let volume = NumberFormatter.localizedString(from: NSNumber(value: entry.unitVolume), number: .decimal)
                let time = timeFormatter.string(from: entry.startDate)

                cell.textLabel?.text = String(
                    format: LocalizedString("%1$@ U", comment: "Reservoir entry (1: volume value)"),
                    volume
                )
                cell.textLabel?.textColor = .label
                cell.detailTextLabel?.text = time
                cell.accessoryType = .none
                cell.selectionStyle = .none
            case let .history(values):
                let entry = values[indexPath.row]
                let time = timeFormatter.string(from: entry.date)

                if let attributedText = entry.dose?.localizedAttributedDescription {
                    cell.textLabel?.attributedText = attributedText
                } else {
                    cell.textLabel?.text = entry.title
                }

                cell.detailTextLabel?.text = time
                cell.accessoryType = entry.isUploaded ? .checkmark : .none
                cell.selectionStyle = .default
            }
        }

        return cell
    }

    override public func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        enableEntryDeletion
    }

    override public func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete, case .display = state {
            switch values {
            case let .reservoir(reservoirValues):
                var reservoirValues = reservoirValues
                let value = reservoirValues.remove(at: indexPath.row)
                self.values = .reservoir(reservoirValues)

                tableView.deleteRows(at: [indexPath], with: .automatic)

                doseStore?.deleteReservoirValue(value) { (_, error) -> Void in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.present(UIAlertController(with: error), animated: true)
                            self.reloadData()
                        }
                    }
                }
            case let .history(historyValues):
                var historyValues = historyValues
                let value = historyValues.remove(at: indexPath.row)
                self.values = .history(historyValues)

                tableView.deleteRows(at: [indexPath], with: .automatic)

                doseStore?.deletePumpEvent(value) { (error) -> Void in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.present(UIAlertController(with: error), animated: true)
                            self.reloadData()
                        }
                    }
                }
            }
        }
    }

    override public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .display = state, case let .history(history) = values {
            let entry = history[indexPath.row]

            let vc = CommandResponseViewController(command: { (_) -> String in
                var description = [String]()

                description.append(self.timeFormatter.string(from: entry.date))

                if let title = entry.title {
                    description.append(title)
                }

                if let dose = entry.dose {
                    description.append(String(describing: dose))
                }

                if let raw = entry.raw {
                    description.append(raw.hexadecimalString)
                }

                return description.joined(separator: "\n\n")
            })

            vc.title = LocalizedString("Pump Event", comment: "The title of the screen displaying a pump event")

            show(vc, sender: indexPath)
        }
    }
}

private extension UIAlertController {
    convenience init(deleteAllConfirmationMessage: String, confirmationHandler handler: @escaping () -> Void) {
        self.init(
            title: nil,
            message: deleteAllConfirmationMessage,
            preferredStyle: .actionSheet
        )

        addAction(UIAlertAction(
            title: LocalizedString("Delete All", comment: "Button title to delete all objects"),
            style: .destructive,
            handler: { _ in handler() }
        ))

        addAction(UIAlertAction(
            title: LocalizedString("Cancel", comment: "The title of the cancel action in an action sheet"),
            style: .cancel
        ))
    }
}

private extension DoseEntry {
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = DoseEntry.unitsPerHour.maxFractionDigits
        return numberFormatter
    }

    var localizedAttributedDescription: NSAttributedString? {
        let font = UIFont.preferredFont(forTextStyle: .body)

        switch type {
        case .bolus:
            let description: String
            if let deliveredUnits = deliveredUnits,
               deliveredUnits != programmedUnits
            {
                description = String(
                    format: LocalizedString(
                        "Interrupted %1$@: <b>%2$@</b> of %3$@ %4$@",
                        comment: "Description of an interrupted bolus dose entry (1: title for dose type, 2: value (? if no value) in bold, 3: programmed value (? if no value), 4: unit)"
                    ),
                    type.localizedDescription,
                    numberFormatter.string(from: deliveredUnits) ?? "?",
                    numberFormatter.string(from: programmedUnits) ?? "?",
                    DoseEntry.units.shortLocalizedUnitString()
                )
            } else {
                description = String(
                    format: LocalizedString(
                        "%1$@: <b>%2$@</b> %3$@",
                        comment: "Description of a bolus dose entry (1: title for dose type, 2: value (? if no value) in bold, 3: unit)"
                    ),
                    type.localizedDescription,
                    numberFormatter.string(from: programmedUnits) ?? "?",
                    DoseEntry.units.shortLocalizedUnitString()
                )
            }

            return createAttributedDescription(from: description, with: font)
        case .basal,
             .tempBasal:
            let description = String(
                format: LocalizedString(
                    "%1$@: <b>%2$@</b> %3$@",
                    comment: "Description of a basal temp basal dose entry (1: title for dose type, 2: value (? if no value) in bold, 3: unit)"
                ),
                type.localizedDescription,
                numberFormatter.string(from: unitsPerHour) ?? "?",
                DoseEntry.unitsPerHour.shortLocalizedUnitString()
            )
            return createAttributedDescription(from: description, with: font)
        case .resume,
             .suspend:
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.secondaryLabel
            ]
            return NSAttributedString(string: type.localizedDescription, attributes: attributes)
        }
    }

    func createAttributedDescription(from description: String, with font: UIFont) -> NSAttributedString? {
        let descriptionWithFont = String(
            format: "<style>body{font-family: '-apple-system', '\(font.fontName)'; font-size: \(font.pointSize);}</style>%@",
            description
        )

        guard let attributedDescription = try? NSMutableAttributedString(
            data: Data(descriptionWithFont.utf8),
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
            ],
            documentAttributes: nil
        )
        else {
            return nil
        }

        attributedDescription
            .enumerateAttribute(.font, in: NSRange(location: 0, length: attributedDescription.length)) { value, range, _ in
                // bold font items have a dominate colour
                if let font = value as? UIFont,
                   font.fontDescriptor.symbolicTraits.contains(.traitBold)
                {
                    attributedDescription.addAttributes([.foregroundColor: UIColor.label], range: range)
                } else {
                    attributedDescription.addAttributes([.foregroundColor: UIColor.secondaryLabel], range: range)
                }
            }

        return attributedDescription
    }
}
