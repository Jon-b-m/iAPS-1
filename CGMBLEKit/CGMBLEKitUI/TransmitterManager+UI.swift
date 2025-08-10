import CGMBLEKit
import HealthKit
import LoopKit
import LoopKitUI
import SwiftUI

extension G5CGMManager: CGMManagerUI {
    public static var onboardingImage: UIImage? {
        nil
    }

    public static func setupViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference _: DisplayGlucosePreference,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool,
        prefersToSkipUserInteraction _: Bool = false
    ) -> SetupUIResult<CGMManagerViewController, CGMManagerUI> {
        let setupVC = TransmitterSetupViewController.instantiateFromStoryboard()
        setupVC.cgmManagerType = self
        return .userInteractionRequired(setupVC)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference: DisplayGlucosePreference,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool
    ) -> CGMManagerViewController {
        let settings = TransmitterSettingsViewController(cgmManager: self, displayGlucosePreference: displayGlucosePreference)
        let nav = CGMManagerSettingsNavigationViewController(rootViewController: settings)
        return nav
    }

    public var smallImage: UIImage? {
        nil
    }

    // TODO: Placeholder.
    public var cgmStatusHighlight: DeviceStatusHighlight? {
        nil
    }

    // TODO: Placeholder.
    public var cgmStatusBadge: DeviceStatusBadge? {
        nil
    }

    // TODO: Placeholder.
    public var cgmLifecycleProgress: DeviceLifecycleProgress? {
        nil
    }
}

extension G6CGMManager: CGMManagerUI {
    public static var onboardingImage: UIImage? {
        nil
    }

    public static func setupViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference _: DisplayGlucosePreference,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool,
        prefersToSkipUserInteraction _: Bool = false
    ) -> SetupUIResult<CGMManagerViewController, CGMManagerUI> {
        let setupVC = TransmitterSetupViewController.instantiateFromStoryboard()
        setupVC.cgmManagerType = self
        return .userInteractionRequired(setupVC)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference: DisplayGlucosePreference,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool
    ) -> CGMManagerViewController {
        let settings = TransmitterSettingsViewController(cgmManager: self, displayGlucosePreference: displayGlucosePreference)
        let nav = CGMManagerSettingsNavigationViewController(rootViewController: settings)
        return nav
    }

    public var smallImage: UIImage? {
        UIImage(named: "g6", in: Bundle(for: TransmitterSetupViewController.self), compatibleWith: nil)!
    }

    // TODO: Placeholder.
    public var cgmStatusHighlight: DeviceStatusHighlight? {
        nil
    }

    // TODO: Placeholder.
    public var cgmStatusBadge: DeviceStatusBadge? {
        nil
    }

    // TODO: Placeholder.
    public var cgmLifecycleProgress: DeviceLifecycleProgress? {
        nil
    }
}
