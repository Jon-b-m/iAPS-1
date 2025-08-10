import SwiftUI

public extension View {
    func insetGroupedListStyle() -> some View {
        modifier(CustomInsetGroupedListStyle())
    }
}

private struct CustomInsetGroupedListStyle: ViewModifier, HorizontalSizeClassOverride {
    @ViewBuilder func body(content: Content) -> some View {
        // For compact sizes (e.g. iPod Touch), don't inset, in order to more efficiently utilize limited real estate
        if horizontalOverride == .compact {
            content
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, horizontalOverride)
        } else {
            content
                .listStyle(InsetGroupedListStyle())
                .environment(\.horizontalSizeClass, horizontalOverride)
        }
    }
}
