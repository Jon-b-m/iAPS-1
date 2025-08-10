import UIKit

public extension UIFont {
    static var titleFontGroupedInset: UIFont {
        UIFontMetrics(forTextStyle: .title1).scaledFont(for: systemFont(ofSize: 28, weight: .semibold))
    }

    static var sectionHeaderFontGroupedInset: UIFont {
        UIFontMetrics(forTextStyle: .headline).scaledFont(for: systemFont(ofSize: 19, weight: .semibold))
    }

    static var footnote: UIFont {
        preferredFont(forTextStyle: .footnote)
    }

    static var instructionTitle: UIFont {
        preferredFont(forTextStyle: .headline)
    }

    static var instructionStep: UIFont {
        UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: systemFont(ofSize: 14))
    }

    static var instructionNumber: UIFont {
        preferredFont(forTextStyle: .subheadline)
    }

    static var inputValue: UIFont {
        UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: systemFont(ofSize: 48))
    }
}
