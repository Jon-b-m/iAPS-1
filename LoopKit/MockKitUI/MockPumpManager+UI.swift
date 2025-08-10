import Foundation
import LoopKit
import LoopKitUI
import MockKit
import SwiftUI

extension MockPumpManager: PumpManagerUI {
    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }

    public static var onboardingImage: UIImage? {
        UIImage(named: "Pump Simulator", in: Bundle(for: MockPumpManagerSettingsViewController.self), compatibleWith: nil) }

    public var smallImage: UIImage? {
        UIImage(named: "Pump Simulator", in: Bundle(for: MockPumpManagerSettingsViewController.self), compatibleWith: nil) }

    public static func setupViewController(
        initialSettings settings: PumpManagerSetupSettings,
        bluetoothProvider _: BluetoothProvider,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool,
        prefersToSkipUserInteraction _: Bool,
        allowedInsulinTypes _: [InsulinType]
    ) -> SetupUIResult<PumpManagerViewController, PumpManagerUI> {
        let mockPumpManager = MockPumpManager()
        mockPumpManager.setMaximumTempBasalRate(settings.maxBasalRateUnitsPerHour)
        mockPumpManager.syncBasalRateSchedule(items: settings.basalSchedule.items, completion: { _ in })
        return .createdAndOnboarded(mockPumpManager)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool,
        allowedInsulinTypes: [InsulinType]
    ) -> PumpManagerViewController {
        let settings = MockPumpManagerSettingsView(
            pumpManager: self,
            supportedInsulinTypes: allowedInsulinTypes,
            appName: appName,
            allowDebugFeatures: allowDebugFeatures
        )
        let hostingController = DismissibleHostingController(
            content: settings,
            isModalInPresentation: false,
            colorPalette: colorPalette
        )
        hostingController.navigationItem.backButtonDisplayMode = .generic
        let nav = PumpManagerSettingsNavigationViewController(rootViewController: hostingController)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    public func deliveryUncertaintyRecoveryViewController(
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool
    ) -> (UIViewController & CompletionNotifying) {
        return DeliveryUncertaintyRecoveryViewController(appName: appName, uncertaintyStartedAt: Date()) {
            self.state.deliveryCommandsShouldTriggerUncertainDelivery = false
            self.state.deliveryIsUncertain = false
        }
    }

    public func hudProvider(
        bluetoothProvider _: BluetoothProvider,
        colorPalette _: LoopUIColorPalette,
        allowedInsulinTypes: [InsulinType]
    ) -> HUDProvider? {
        MockHUDProvider(pumpManager: self, allowedInsulinTypes: allowedInsulinTypes)
    }

    public static func createHUDView(rawValue: HUDProvider.HUDViewRawState) -> BaseHUDView? {
        MockHUDProvider.createHUDView(rawValue: rawValue)
    }
}

public enum MockPumpStatusBadge: DeviceStatusBadge {
    case timeSyncNeeded

    public var image: UIImage? {
        switch self {
        case .timeSyncNeeded:
            return UIImage(systemName: "clock.fill")
        }
    }

    public var state: DeviceStatusBadgeState {
        switch self {
        case .timeSyncNeeded:
            return .warning
        }
    }
}

// MARK: - PumpStatusIndicator

public extension MockPumpManager {
    var pumpStatusHighlight: DeviceStatusHighlight? {
        buildPumpStatusHighlight(for: state)
    }

    var pumpLifecycleProgress: DeviceLifecycleProgress? {
        buildPumpLifecycleProgress(for: state)
    }

    var pumpStatusBadge: DeviceStatusBadge? {
        isClockOffset ? MockPumpStatusBadge.timeSyncNeeded : nil
    }
}
