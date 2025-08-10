import SwiftUI

public protocol HorizontalSizeClassOverride {
    var horizontalOverride: UserInterfaceSizeClass { get }
}

public extension HorizontalSizeClassOverride {
    var horizontalOverride: UserInterfaceSizeClass {
        if UIScreen.main.bounds.height <= 640 {
            return .compact
        } else {
            return .regular
        }
    }
}
