import UIKit

public class SetupButton: UIButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        backgroundColor = tintColor
        layer.cornerRadius = 6

        titleLabel?.adjustsFontForContentSizeCategory = true
        contentEdgeInsets.top = 14
        contentEdgeInsets.bottom = 14
        setTitleColor(.white, for: .normal)
    }

    override public func tintColorDidChange() {
        super.tintColorDidChange()

        backgroundColor = tintColor
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        tintColor = .blue
        tintColorDidChange()
    }

    override public var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }

    override public var isEnabled: Bool {
        didSet {
            tintAdjustmentMode = isEnabled ? .automatic : .dimmed
        }
    }
}
