import UIKit

protocol InsulinSensitivityScalingTableViewCellDelegate: AnyObject {
    func insulinSensitivityScalingTableViewCellDidUpdateScaleFactor(_ cell: InsulinSensitivityScalingTableViewCell)
}

final class InsulinSensitivityScalingTableViewCell: UITableViewCell {
    private let allScaleFactorPercentages = Array(stride(from: 10, through: 200, by: 10))

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var valueLabel: UILabel!

    @IBOutlet var gaugeBar: SegmentedGaugeBarView! {
        didSet {
            gaugeBar.backgroundColor = .systemGray6

            gaugeBar.delegate = self
        }
    }

    @IBOutlet private var scaleFactorPicker: UIPickerView! {
        didSet {
            scaleFactorPicker.dataSource = self
            scaleFactorPicker.delegate = self
        }
    }

    @IBOutlet private var scaleFactorPickerHeightConstraint: NSLayoutConstraint! {
        didSet {
            pickerExpandedHeight = scaleFactorPickerHeightConstraint.constant
        }
    }

    private var pickerExpandedHeight: CGFloat = 0

    @IBOutlet private var footerLabel: UILabel!

    private lazy var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var isPickerHidden: Bool {
        get {
            scaleFactorPicker.isHidden
        }
        set {
            scaleFactorPicker.isHidden = newValue
            scaleFactorPickerHeightConstraint.constant = newValue ? 0 : pickerExpandedHeight

            if !newValue {
                updatePickerRow(animated: false)
            }
        }
    }

    private func updatePickerRow(animated: Bool) {
        var selectedRow = allScaleFactorPercentages.firstIndex(of: selectedPercentage)
        if selectedRow == nil {
            let truncatedPercentage = allScaleFactorPercentages
                .adjacentPairs()
                .first(where: { lower, upper in
                    (lower ..< upper).contains(selectedPercentage)
                })?.0 ?? 100
            selectedRow = allScaleFactorPercentages.firstIndex(of: truncatedPercentage)
        }

        scaleFactorPicker.selectRow(selectedRow!, inComponent: 0, animated: animated)
    }

    private var selectedPercentage = 100 {
        didSet {
            gaugeBar.progress = Double(selectedPercentage) / 100
            valueLabel.text = percentageString(from: selectedPercentage)
            updateFooterLabel()
            delegate?.insulinSensitivityScalingTableViewCellDidUpdateScaleFactor(self)
        }
    }

    var scaleFactor: Double {
        get {
            Double(selectedPercentage) / 100
        }
        set {
            let domain = allScaleFactorPercentages.first! ... allScaleFactorPercentages.last!
            selectedPercentage = Int(round(newValue * 100)).clamped(to: domain)
        }
    }

    weak var delegate: InsulinSensitivityScalingTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = LocalizedString(
            "Overall Insulin Needs",
            comment: "The title text for the insulin sensitivity scaling setting"
        )

        selectedPercentage = 100
        setSelected(true, animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Save and reassign the background color to avoid propagated transparency during the animation.
        let gaugeBarBackgroundColor = gaugeBar.backgroundColor
        super.setSelected(selected, animated: animated)

        if selected {
            gaugeBar.backgroundColor = gaugeBarBackgroundColor
            isPickerHidden.toggle()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Save and reassign the background color to avoid propagated transparency during the animation.
        let gaugeBarBackgroundColor = gaugeBar.backgroundColor
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            gaugeBar.backgroundColor = gaugeBarBackgroundColor
        }
    }

    private func updateFooterLabel() {
        let footerText: String

        let delta = selectedPercentage - 100
        if delta < 0 {
            footerText = String(
                format: LocalizedString(
                    "Basal, bolus, and correction insulin dose amounts are decreased by %@%%.",
                    comment: "Describes a percentage decrease in overall insulin needs"
                ),
                String(abs(delta))
            )
        } else if delta > 0 {
            footerText = String(
                format: LocalizedString(
                    "Basal, bolus, and correction insulin dose amounts are increased by %@%%.",
                    comment: "Describes a percentage increase in overall insulin needs"
                ),
                String(delta)
            )
        } else {
            footerText = LocalizedString(
                "Basal, bolus, and correction insulin dose amounts are unaffected.",
                comment: "Describes a lack of change in overall insulin needs"
            )
        }

        footerLabel.text = footerText
    }

    private func percentageString(from percentage: Int) -> String? {
        percentFormatter.string(from: Double(percentage) / 100)
    }
}

extension InsulinSensitivityScalingTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        allScaleFactorPercentages.count
    }
}

extension InsulinSensitivityScalingTableViewCell: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        percentageString(from: allScaleFactorPercentages[row])
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedPercentage = allScaleFactorPercentages[row]
    }
}

extension InsulinSensitivityScalingTableViewCell: SegmentedGaugeBarViewDelegate {
    func segmentedGaugeBarView(_: SegmentedGaugeBarView, didUpdateProgressFrom _: Double, to newValue: Double) {
        scaleFactor = newValue
        updatePickerRow(animated: true)
    }
}

extension InsulinSensitivityScalingTableViewCellDelegate where Self: UITableViewController {
    func collapseInsulinSensitivityScalingCells(excluding indexPath: IndexPath? = nil) {
        for case let cell as InsulinSensitivityScalingTableViewCell in tableView.visibleCells
            where tableView.indexPath(for: cell) != indexPath && !cell.isPickerHidden
        {
            cell.isPickerHidden = true
        }
    }
}
