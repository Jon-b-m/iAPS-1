import UIKit

extension UIColor {
    static let delete = UIColor.higRed()
}

// MARK: - HIG colors

// See: https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/
extension UIColor {
    private static func higRed() -> UIColor {
        UIColor(red: 1, green: 59 / 255, blue: 48 / 255, alpha: 1)
    }
}
