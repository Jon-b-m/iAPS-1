import LoopKit
import LoopKitUI
import MinimedKit
import RileyLinkKitUI
import SwiftUI
import UIKit

extension MinimedPumpManager: PumpManagerUI {
    public static var onboardingImage: UIImage? {
        UIImage.pumpImage(in: nil, isLargerModel: false, isSmallImage: true)
    }

    public static func setupViewController(
        initialSettings settings: PumpManagerSetupSettings,
        bluetoothProvider _: BluetoothProvider,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool,
        prefersToSkipUserInteraction _: Bool,
        allowedInsulinTypes: [InsulinType]
    ) -> SetupUIResult<PumpManagerViewController, PumpManagerUI> {
        let navVC = MinimedPumpManagerSetupViewController.instantiateFromStoryboard()
        navVC.supportedInsulinTypes = allowedInsulinTypes
        let didConfirm: (InsulinType) -> Void = { [weak navVC] confirmedType in
            if let navVC = navVC {
                navVC.insulinType = confirmedType
                let nextViewController = navVC.storyboard?
                    .instantiateViewController(identifier: "RileyLinkSetup") as! RileyLinkSetupTableViewController
                navVC.pushViewController(nextViewController, animated: true)
            }
        }
        let didCancel: () -> Void = { [weak navVC] in
            if let navVC = navVC {
                navVC.didCancel()
            }
        }
        let insulinSelectionView = InsulinTypeConfirmation(
            initialValue: .novolog,
            supportedInsulinTypes: allowedInsulinTypes,
            didConfirm: didConfirm,
            didCancel: didCancel
        )
        let rootVC = UIHostingController(rootView: insulinSelectionView)
        rootVC.title = "Insulin Type"
        navVC.pushViewController(rootVC, animated: false)
        navVC.navigationBar.backgroundColor = .secondarySystemBackground
        navVC.maxBasalRateUnitsPerHour = settings.maxBasalRateUnitsPerHour
        navVC.maxBolusUnits = settings.maxBolusUnits
        navVC.basalSchedule = settings.basalSchedule
        return .userInteractionRequired(navVC)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool,
        allowedInsulinTypes: [InsulinType]
    ) -> PumpManagerViewController {
        MinimedUICoordinator(
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
        return MinimedUICoordinator(
            pumpManager: self,
            colorPalette: colorPalette,
            allowDebugFeatures: allowDebugFeatures,
            allowedInsulinTypes: []
        )
    }

    public var smallImage: UIImage? {
        state.smallPumpImage
    }

    public func hudProvider(
        bluetoothProvider: BluetoothProvider,
        colorPalette: LoopUIColorPalette,
        allowedInsulinTypes: [InsulinType]
    ) -> HUDProvider? {
        MinimedHUDProvider(
            pumpManager: self,
            bluetoothProvider: bluetoothProvider,
            colorPalette: colorPalette,
            allowedInsulinTypes: allowedInsulinTypes
        )
    }

    public static func createHUDView(rawValue: HUDProvider.HUDViewRawState) -> BaseHUDView? {
        MinimedHUDProvider.createHUDView(rawValue: rawValue)
    }
}

public enum MinimedStatusBadge: DeviceStatusBadge {
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

public extension MinimedPumpManager {
    var pumpStatusHighlight: DeviceStatusHighlight? {
        buildPumpStatusHighlight(for: state, recents: recents, andDate: dateGenerator())
    }

    var pumpLifecycleProgress: DeviceLifecycleProgress? {
        nil
    }

    var pumpStatusBadge: DeviceStatusBadge? {
        if isClockOffset {
            return MinimedStatusBadge.timeSyncNeeded
        } else {
            return nil
        }
    }
}
