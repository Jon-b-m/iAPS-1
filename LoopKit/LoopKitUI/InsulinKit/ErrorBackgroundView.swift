import UIKit

public class ErrorBackgroundView: UIView {
    @IBOutlet var errorDescriptionLabel: UILabel!

    public func setErrorDescriptionLabel(with label: String?) {
        guard let label = label else {
            return
        }

        errorDescriptionLabel.text = label
    }
}
