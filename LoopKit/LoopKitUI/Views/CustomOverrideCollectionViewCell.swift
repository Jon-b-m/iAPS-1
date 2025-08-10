import UIKit

final class CustomOverrideCollectionViewCell: UICollectionViewCell, IdentifiableClass {
    @IBOutlet var titleLabel: UILabel!

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

        addSubview(overlayDimmerView)
        NSLayoutConstraint.activate([
            overlayDimmerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayDimmerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayDimmerView.topAnchor.constraint(equalTo: topAnchor),
            overlayDimmerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        removeOverlay(animated: false)
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
}
