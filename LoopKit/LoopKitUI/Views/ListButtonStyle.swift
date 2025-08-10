import SwiftUI

public struct ListButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                Color(UIColor.tertiarySystemFill)
                    .opacity(configuration.isPressed ? 0.5 : 0)
            )
    }
}
