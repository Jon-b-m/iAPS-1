import LoopKit
import MockKit
import SwiftUI

struct MockPumpManagerControlsView: UIViewControllerRepresentable {
    private let pumpManager: MockPumpManager
    private let supportedInsulinTypes: [InsulinType]

    init(pumpManager: MockPumpManager, supportedInsulinTypes: [InsulinType]) {
        self.pumpManager = pumpManager
        self.supportedInsulinTypes = supportedInsulinTypes
    }

    final class Coordinator: NSObject {
        private let parent: MockPumpManagerControlsView

        init(_ parent: MockPumpManagerControlsView) {
            self.parent = parent
        }
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        MockPumpManagerSettingsViewController(pumpManager: pumpManager, supportedInsulinTypes: supportedInsulinTypes)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}
