import UIKit

public class TableViewTitleLabel: UILabel {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initFont()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initFont()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        initFont()
    }

    public func initFont() {
        font = UIFont.titleFontGroupedInset
        adjustsFontForContentSizeCategory = true
    }
}
