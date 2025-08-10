import SwiftUI

public struct GuidanceColors {
    public var acceptable: Color
    public var warning: Color
    public var critical: Color

    public init(acceptable: Color, warning: Color, critical: Color)
    {
        self.acceptable = acceptable
        self.warning = warning
        self.critical = critical
    }

    public init() {
        acceptable = .primary
        warning = .yellow
        critical = .red
    }
}
