import SwiftUI

private struct PresentationDismissalKey: EnvironmentKey {
    static let defaultValue = {}
}

public extension EnvironmentValues {
    var dismissAction: () -> Void {
        get { self[PresentationDismissalKey.self] }
        set { self[PresentationDismissalKey.self] = newValue }
    }
}
