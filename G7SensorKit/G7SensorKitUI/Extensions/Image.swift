import Foundation
import SwiftUI

extension Image {
    init(frameworkImage name: String, decorative: Bool = false) {
        if decorative {
            self.init(decorative: name, bundle: FrameworkBundle.main)
        } else {
            self.init(name, bundle: FrameworkBundle.main)
        }
    }
}
