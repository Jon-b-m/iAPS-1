import LoopKitUI
import MockKit
import SwiftUI

struct MockCGMManagerControlsView: UIViewControllerRepresentable {
    private let cgmManager: MockCGMManager
    private let displayGlucosePreference: DisplayGlucosePreference

    init(cgmManager: MockCGMManager, displayGlucosePreference: DisplayGlucosePreference) {
        self.cgmManager = cgmManager
        self.displayGlucosePreference = displayGlucosePreference
    }

    final class Coordinator: NSObject {
        private let parent: MockCGMManagerControlsView

        init(_ parent: MockCGMManagerControlsView) {
            self.parent = parent
        }
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        MockCGMManagerSettingsViewController(cgmManager: cgmManager, displayGlucosePreference: displayGlucosePreference)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}
