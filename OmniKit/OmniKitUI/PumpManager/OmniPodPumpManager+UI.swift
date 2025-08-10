import Foundation
import LoopKit
import LoopKitUI
import OmniKit
import RileyLinkKitUI
import SwiftUI
import UIKit

extension OmnipodPumpManager: PumpManagerUI {
    public static var onboardingImage: UIImage? {
        UIImage(named: "Onboarding", in: Bundle(for: OmnipodSettingsViewModel.self), compatibleWith: nil)
    }

    public static func setupViewController(
        initialSettings settings: PumpManagerSetupSettings,
        bluetoothProvider _: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool,
        prefersToSkipUserInteraction _: Bool,
        allowedInsulinTypes: [InsulinType]
    ) -> SetupUIResult<PumpManagerViewController, PumpManagerUI>
    {
        let vc = OmnipodUICoordinator(
            colorPalette: colorPalette,
            pumpManagerSettings: settings,
            allowDebugFeatures: allowDebugFeatures,
            allowedInsulinTypes: allowedInsulinTypes
        )
        return .userInteractionRequired(vc)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool,
        allowedInsulinTypes: [InsulinType]
    ) -> PumpManagerViewController {
        OmnipodUICoordinator(
            pumpManager: self,
            colorPalette: colorPalette,
            allowDebugFeatures: allowDebugFeatures,
            allowedInsulinTypes: allowedInsulinTypes
        )
    }

    public func deliveryUncertaintyRecoveryViewController(
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool
    ) -> (UIViewController & CompletionNotifying) {
        return OmnipodUICoordinator(pumpManager: self, colorPalette: colorPalette, allowDebugFeatures: allowDebugFeatures)
    }

    public var smallImage: UIImage? {
        UIImage(named: "Pod", in: Bundle(for: OmnipodSettingsViewModel.self), compatibleWith: nil)!
    }

    public func hudProvider(
        bluetoothProvider: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowedInsulinTypes: [InsulinType]
    ) -> HUDProvider? {
        OmnipodHUDProvider(
            pumpManager: self,
            bluetoothProvider: bluetoothProvider,
            colorPalette: colorPalette,
            allowedInsulinTypes: allowedInsulinTypes
        )
    }

    public static func createHUDView(rawValue: HUDProvider.HUDViewRawState) -> BaseHUDView? {
        OmnipodHUDProvider.createHUDView(rawValue: rawValue)
    }
}

public enum OmniKitStatusBadge: DeviceStatusBadge {
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

public extension OmnipodPumpManager {
    var pumpStatusHighlight: DeviceStatusHighlight? {
        buildPumpStatusHighlight(for: state)
    }

    var pumpLifecycleProgress: DeviceLifecycleProgress? {
        buildPumpLifecycleProgress(for: state)
    }

    var pumpStatusBadge: DeviceStatusBadge? {
        if isClockOffset {
            return OmniKitStatusBadge.timeSyncNeeded
        } else {
            return nil
        }
    }
}
