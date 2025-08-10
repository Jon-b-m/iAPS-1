import SwiftUI

private class FrameworkBundle {
    static let main = Bundle(for: FrameworkBundle.self)
}

extension Image {
    init(frameworkImage name: String) {
        self.init(name, bundle: FrameworkBundle.main)
    }
}
