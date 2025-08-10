import Foundation

import HealthKit
import LoopKit
import LoopKitUI
import MockKit
import UIKit

protocol SupportedRangeTableViewControllerDelegate: AnyObject {
    func supportedRangeDidUpdate(_ controller: SupportedRangeTableViewController)
}

final class SupportedRangeTableViewController: UITableViewController {
    weak var delegate: SupportedRangeTableViewControllerDelegate?

    var minValue: Double

    var maxValue: Double

    var stepSize: Double

    var indexPath: IndexPath?

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3

        return formatter
    }()

    init(
        minValue: Double,
        maxValue: Double,
        stepSize: Double
    )
    {
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepSize = stepSize
        super.init(style: .grouped)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.className)
    }

    // MARK: - Data Source

    private enum Row: Int, CaseIterable {
        case minValue = 0
        case maxValue
        case stepSize
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        "Changing the supported values of the pump may cause the app to crash. Ensure you are changing them such that the set therapy values are still valid (e.g., basal rate, max bolus, etc.)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsTableViewCell.className,
            for: indexPath
        ) as! SettingsTableViewCell

        switch Row(rawValue: indexPath.row)! {
        case .minValue:
            cell.textLabel?.text = "Minimum Value"
            cell.detailTextLabel?.text = numberFormatter.string(from: minValue)
        case .maxValue:
            cell.textLabel?.text = "Maximum Value"
            cell.detailTextLabel?.text = numberFormatter.string(from: maxValue)
        case .stepSize:
            cell.textLabel?.text = "Step Size"
            cell.detailTextLabel?.text = numberFormatter.string(from: stepSize)
        }

        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender = tableView.cellForRow(at: indexPath)

        let value: Double
        switch Row(rawValue: indexPath.row)! {
        case .minValue:
            value = minValue
        case .maxValue:
            value = maxValue
        case .stepSize:
            value = stepSize
        }

        let vc = TextFieldTableViewController()
        vc.value = numberFormatter.string(from: value)
        vc.keyboardType = .decimalPad
        vc.indexPath = indexPath
        vc.delegate = self
        show(vc, sender: sender)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SupportedRangeTableViewController: TextFieldTableViewControllerDelegate {
    func textFieldTableViewControllerDidReturn(_ controller: TextFieldTableViewController) {
        update(from: controller)
    }

    func textFieldTableViewControllerDidEndEditing(_ controller: TextFieldTableViewController) {
        update(from: controller)
    }

    private func update(from controller: TextFieldTableViewController) {
        guard let indexPath = controller.indexPath,
              let value = controller.value.flatMap(Double.init)
        else { assertionFailure()
            return }

        switch Row(rawValue: indexPath.row)! {
        case .minValue:
            minValue = max(value, 0.0)
        case .maxValue:
            maxValue = max(value, 0.0)
        case .stepSize:
            stepSize = max(value, 0.0)
        }

        delegate?.supportedRangeDidUpdate(self)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
