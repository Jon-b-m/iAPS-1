import UIKit

open class TextButtonTableViewCell: LoadingTableViewCell {
    override public init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        textLabel?.tintAdjustmentMode = .automatic
        textLabel?.textColor = tintColor
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public var isEnabled = true {
        didSet {
            tintAdjustmentMode = isEnabled ? .normal : .dimmed
            selectionStyle = isEnabled ? .default : .none
        }
    }

    override open func tintColorDidChange() {
        super.tintColorDidChange()

        textLabel?.textColor = tintColor
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        textLabel?.textColor = tintColor
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        textLabel?.textAlignment = .natural
        tintColor = nil
        isEnabled = true
    }
}
