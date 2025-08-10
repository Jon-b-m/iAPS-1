import UIKit

protocol OverridePresetCollectionViewCellDelegate: AnyObject {
    func overridePresetCollectionViewCellDidScheduleOverride(_ cell: OverridePresetCollectionViewCell)
    func overridePresetCollectionViewCellDidPerformFirstDeletionStep(_ cell: OverridePresetCollectionViewCell)
    func overridePresetCollectionViewCellDidDeletePreset(_ cell: OverridePresetCollectionViewCell)
}

final class OverridePresetCollectionViewCell: UICollectionViewCell, IdentifiableClass {
    @IBOutlet var symbolLabel: UILabel!

    @IBOutlet var startTimeLabel: UILabel! {
        didSet {
            startTimeLabel.text?.removeAll()
        }
    }

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var targetRangeLabel: UILabel! {
        didSet {
            targetRangeLabel.text?.removeAll()
        }
    }

    @IBOutlet var insulinNeedsBar: SegmentedGaugeBarView! {
        didSet {
            insulinNeedsBar.backgroundColor = .systemGray6

            insulinNeedsBar.isUserInteractionEnabled = false
        }
    }

    @IBOutlet private var durationStackView: UIStackView!
    @IBOutlet var durationLabel: UILabel!

    @IBOutlet var scheduleButton: UIButton!

    @IBOutlet private var editingIndicator: UIImageView! {
        didSet {
            editingIndicator.alpha = 0
        }
    }

    @IBOutlet private var deleteButton: UIButton! {
        didSet {
            deleteButton.layer.cornerRadius = 4
        }
    }

    @IBOutlet private var deleteButtonWidthConstraint: NSLayoutConstraint! {
        didSet {
            deleteButtonWidthConstraint.constant = 0
        }
    }

    weak var delegate: OverridePresetCollectionViewCellDelegate?

    private lazy var overlayDimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        let selectedBackgroundView = UIView()
        self.selectedBackgroundView = selectedBackgroundView

        selectedBackgroundView.backgroundColor = .tertiarySystemFill

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerCurve = .continuous

        layer.cornerRadius = 16

        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        addSubview(overlayDimmerView)
        NSLayoutConstraint.activate([
            overlayDimmerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayDimmerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayDimmerView.topAnchor.constraint(equalTo: topAnchor),
            overlayDimmerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        startTimeLabel.text?.removeAll()
        targetRangeLabel.isHidden = false
        insulinNeedsBar.isHidden = false
        configureForStandard(animated: false)
        removeOverlay(animated: false)
    }

    func configureForEditing(animated: Bool) {
        func makeVisualChanges() {
            durationStackView.alpha = 0
            scheduleButton.alpha = 0
            editingIndicator.alpha = 1
            deleteButtonWidthConstraint.constant = 32
            deleteButton.setImage(UIImage(systemName: "xmark")!, for: .normal)
            deleteButton.setTitle(nil, for: .normal)
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                makeVisualChanges()
                self.layoutIfNeeded()
            })
        } else {
            makeVisualChanges()
        }

        isShowingFinalDeleteConfirmation = false
    }

    func configureForStandard(animated: Bool) {
        func makeVisualChanges() {
            durationStackView.alpha = 1
            scheduleButton.alpha = 1
            editingIndicator.alpha = 0
            deleteButtonWidthConstraint.constant = 0
            deleteButton.setImage(UIImage(systemName: "xmark")!, for: .normal)
            deleteButton.setTitle(nil, for: .normal)
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                makeVisualChanges()
                self.layoutIfNeeded()
            })
        } else {
            makeVisualChanges()
        }

        isShowingFinalDeleteConfirmation = false
    }

    func applyOverlayToFade(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.overlayDimmerView.alpha = 0.5
            })
        } else {
            overlayDimmerView.alpha = 0.5
        }
    }

    func removeOverlay(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.overlayDimmerView.alpha = 0
            })
        } else {
            overlayDimmerView.alpha = 0
        }
    }

    @objc private func scheduleButtonTapped() {
        delegate?.overridePresetCollectionViewCellDidScheduleOverride(self)
    }

    private(set) var isShowingFinalDeleteConfirmation = false

    @IBAction private func deleteButtonTapped(_: UIButton) {
        if isShowingFinalDeleteConfirmation {
            delegate?.overridePresetCollectionViewCellDidDeletePreset(self)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteButton.setImage(nil, for: .normal)
                self.deleteButton.setTitle("Delete", for: .normal)
                self.deleteButtonWidthConstraint.constant = 72
                self.layoutIfNeeded()
            })

            isShowingFinalDeleteConfirmation = true
            delegate?.overridePresetCollectionViewCellDidPerformFirstDeletionStep(self)
        }
    }
}
