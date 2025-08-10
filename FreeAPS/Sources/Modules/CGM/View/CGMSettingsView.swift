import LoopKit
import LoopKitUI
import SwiftUI
import UIKit

extension CGM {
    struct CGMSetupView: UIViewControllerRepresentable {
        let CGMType: cgmName
        let bluetoothManager: BluetoothStateManager
        let unit: GlucoseUnits
        weak var completionDelegate: CompletionDelegate?
        weak var setupDelegate: CGMManagerOnboardingDelegate?
        let pluginCGMManager: PluginManager

        func makeUIViewController(context _: UIViewControllerRepresentableContext<CGMSetupView>) -> UIViewController {
            var setupViewController: SetupUIResult<
 @@ -31,38 +26,19 @@ extension CGM {
                displayGlucosePreference = DisplayGlucosePreference(displayGlucoseUnit: .millimolesPerLiter)
            }

            switch CGMType.type {
            case .plugin:
                if let cgmManagerUIType = pluginCGMManager.getCGMManagerTypeByIdentifier(CGMType.id) {
                    setupViewController = cgmManagerUIType.setupViewController(
                        bluetoothProvider: bluetoothManager,
                        displayGlucosePreference: displayGlucosePreference,
                        colorPalette: .default,
                        allowDebugFeatures: false,
                        prefersToSkipUserInteraction: false
                    )
                } else {
                    break
                }
            default:
                break
            }
