import UIKit

private let Margin: CGFloat = 8

public final class ValidatingIndicatorView: UIView {
    let indicatorView = UIActivityIndicatorView(style: .default)

    let label = UILabel()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        label.text = LocalizedString("Verifying", comment: "Label indicating validation is occurring")
        label.sizeToFit()

        addSubview(indicatorView)
        addSubview(label)

        self.frame.size = intrinsicContentSize

        setNeedsLayout()

        indicatorView.startAnimating()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        // Center the label in the bounds so it appears aligned, then let the indicator view hang from the left side
        label.frame = bounds
        indicatorView.center.y = bounds.midY
        indicatorView.frame.origin.x = -indicatorView.frame.size.width - Margin
    }

    override public var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }
}
