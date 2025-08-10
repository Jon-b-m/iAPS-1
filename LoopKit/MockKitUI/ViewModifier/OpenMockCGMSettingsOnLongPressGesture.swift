import LoopKitUI
import MockKit
import SwiftUI

extension View {
    func openMockCGMSettingsOnLongPress(
        enabled: Bool = true,
        minimumDuration: Double = 5,
        cgmManager: MockCGMManager,
        displayGlucosePreference: DisplayGlucosePreference
    ) -> some View {
        modifier(OpenMockCGMSettingsOnLongPressGesture(
            enabled: enabled,
            minimumDuration: minimumDuration,
            cgmManager: cgmManager,
            displayGlucosePreference: displayGlucosePreference
        ))
    }
}

private struct OpenMockCGMSettingsOnLongPressGesture: ViewModifier {
    private let enabled: Bool
    private let minimumDuration: TimeInterval
    private let cgmManager: MockCGMManager
    private let displayGlucosePreference: DisplayGlucosePreference
    @State private var mockCGMSettingsDisplayed = false

    init(enabled: Bool, minimumDuration: Double, cgmManager: MockCGMManager, displayGlucosePreference: DisplayGlucosePreference) {
        self.enabled = enabled
        self.minimumDuration = minimumDuration
        self.cgmManager = cgmManager
        self.displayGlucosePreference = displayGlucosePreference
    }

    func body(content: Content) -> some View {
        modifiedContent(content: content)
    }

    func modifiedContent(content: Content) -> some View {
        ZStack {
            content
                .onLongPressGesture(minimumDuration: minimumDuration) {
                    mockCGMSettingsDisplayed = true
                }
            NavigationLink(
                destination: MockCGMManagerControlsView(
                    cgmManager: cgmManager,
                    displayGlucosePreference: displayGlucosePreference
                ),
                isActive: $mockCGMSettingsDisplayed
            ) {
                EmptyView()
            }
            .opacity(0) // <- Hides the Chevron
            .buttonStyle(PlainButtonStyle())
            .disabled(true)
        }
    }
}
