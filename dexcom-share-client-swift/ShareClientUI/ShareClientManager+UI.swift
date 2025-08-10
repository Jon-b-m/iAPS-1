import HealthKit
import LoopKit
import LoopKitUI
import ShareClient
import SwiftUI

extension ShareClientManager: CGMManagerUI {
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
        .userInteractionRequired(ShareClientSetupViewController())
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference: DisplayGlucosePreference,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool
    ) -> CGMManagerViewController {
        let settings = ShareClientSettingsViewController(
            cgmManager: self,
            displayGlucosePreference: displayGlucosePreference,
            allowsDeletion: true
        )
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
