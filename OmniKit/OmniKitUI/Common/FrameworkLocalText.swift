import Foundation
import SwiftUI

private class FrameworkReferenceClass {
    static let bundle = Bundle(for: FrameworkReferenceClass.self)
}

func FrameworkLocalText(_ key: LocalizedStringKey, comment: StaticString) -> Text {
    Text(key, bundle: FrameworkReferenceClass.bundle, comment: comment)
}
