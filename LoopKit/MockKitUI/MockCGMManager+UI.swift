import HealthKit
import LoopKit
import LoopKitUI
import MockKit
import SwiftUI
import UIKit

extension MockCGMManager: CGMManagerUI {
    fileprivate var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }

    public static var onboardingImage: UIImage? {
        UIImage(named: "CGM Simulator", in: Bundle(for: MockCGMManagerSettingsViewController.self), compatibleWith: nil) }

    public var smallImage: UIImage? {
        UIImage(named: "CGM Simulator", in: Bundle(for: MockCGMManagerSettingsViewController.self), compatibleWith: nil) }

    public static func setupViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference _: DisplayGlucosePreference,
        colorPalette _: LoopUIColorPalette,
        allowDebugFeatures _: Bool,
        prefersToSkipUserInteraction _: Bool
    ) -> SetupUIResult<CGMManagerViewController, CGMManagerUI> {
        .createdAndOnboarded(MockCGMManager())
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference: DisplayGlucosePreference,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool
    ) -> CGMManagerViewController {
        let settings = MockCGMManagerSettingsView(
            cgmManager: self,
            displayGlucosePreference: displayGlucosePreference,
            appName: appName,
            allowDebugFeatures: allowDebugFeatures
        )
        let hostingController = DismissibleHostingController(
            content: settings,
            isModalInPresentation: false,
            colorPalette: colorPalette
        )
        hostingController.navigationItem.backButtonDisplayMode = .generic
        let nav = CGMManagerSettingsNavigationViewController(rootViewController: hostingController)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    public var cgmStatusBadge: DeviceStatusBadge? {
        mockSensorState.cgmStatusBadge
    }

    public var cgmStatusHighlight: DeviceStatusHighlight? {
        mockSensorState.cgmStatusHighlight
    }

    public var cgmLifecycleProgress: DeviceLifecycleProgress? {
        mockSensorState.cgmLifecycleProgress
    }
}
