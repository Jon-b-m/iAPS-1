import UIKit

open class SwitchTableViewCell: UITableViewCell {
    public var `switch`: UISwitch?

    override public init(style _: UITableViewCell.CellStyle, reuseIdentifier _: String?) {
        super.init(style: .value1, reuseIdentifier: Self.className)

        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUp()
    }

    private func setUp() {
        `switch` = UISwitch(frame: .zero)
        accessoryView = `switch`
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutMargins.left = separatorInset.left
        contentView.layoutMargins.right = separatorInset.left
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        self.switch?.removeTarget(nil, action: nil, for: .valueChanged)
    }
}
