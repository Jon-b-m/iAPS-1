import UIKit

class GlucoseRangeOverrideTableViewCell: GlucoseRangeTableViewCell {
    // MARK: Outlets

    @IBOutlet var iconImageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        allowTimeSelection = false
    }
}
