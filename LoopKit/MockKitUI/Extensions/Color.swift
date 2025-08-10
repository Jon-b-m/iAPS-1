import SwiftUI

private class FrameworkBundle {
    static let main = Bundle(for: FrameworkBundle.self)
}

extension Color {
    init?(frameworkColor name: String) {
        self.init(name, bundle: FrameworkBundle.main)
    }
}
