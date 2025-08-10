import UIKit

public class RileyLinkDevicesHeaderView: UITableViewHeaderFooterView, IdentifiableClass {
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    public let spinner = UIActivityIndicatorView(style: .default)

    private func setup() {
        contentView.addSubview(spinner)
        spinner.startAnimating()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        spinner.center.y = textLabel?.center.y ?? 0
        spinner.frame.origin.x = contentView.bounds.size.width - contentView.directionalLayoutMargins.trailing - spinner.frame
            .size.width
    }
}
