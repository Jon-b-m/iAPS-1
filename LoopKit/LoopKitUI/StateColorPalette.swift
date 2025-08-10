import UIKit

/// A collection of colors for displaying state
public struct StateColorPalette {
    public let unknown: UIColor
    public let normal: UIColor
    public let warning: UIColor
    public let error: UIColor

    public init(unknown: UIColor, normal: UIColor, warning: UIColor, error: UIColor) {
        self.unknown = unknown
        self.normal = normal
        self.warning = warning
        self.error = error
    }
}
