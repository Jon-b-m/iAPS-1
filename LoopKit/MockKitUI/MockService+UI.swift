import HealthKit
import LoopKit
import LoopKitUI
import MockKit
import SwiftUI

extension MockService: ServiceUI {
    public static var image: UIImage? {
        UIImage(systemName: "icloud.and.arrow.up")
    }

    public static func setupViewController(
        colorPalette _: LoopUIColorPalette,
        pluginHost _: PluginHost
    ) -> SetupUIResult<ServiceViewController, ServiceUI> {
        .userInteractionRequired(
            ServiceNavigationController(rootViewController: MockServiceTableViewController(
                service: MockService(),
                for: .create
            ))
        )
    }

    public func settingsViewController(colorPalette _: LoopUIColorPalette) -> ServiceViewController {
        ServiceNavigationController(rootViewController: MockServiceTableViewController(service: self, for: .update))
    }
}
