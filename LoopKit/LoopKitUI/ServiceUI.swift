import LoopKit
import SwiftUI

public struct ServiceDescriptor {
    public let identifier: String
    public let localizedTitle: String

    public init(identifier: String, localizedTitle: String) {
        self.identifier = identifier
        self.localizedTitle = localizedTitle
    }
}

public typealias ServiceViewController = (UIViewController & ServiceOnboarding & CompletionNotifying)

public protocol ServiceUI: Service {
    /// The image for this type of service.
    static var image: UIImage? { get }

    /// Create and onboard a new service.
    ///
    /// - Parameters:
    ///     - colorPalette: Color palette to use for any UI.
    ///     - pluginHost: Object that provides namd and version  information about host to the service plugin.
    /// - Returns: Either a conforming view controller to create and onboard the service or a newly created and onboarded service.
    static func setupViewController(colorPalette: LoopUIColorPalette, pluginHost: PluginHost)
        -> SetupUIResult<ServiceViewController, ServiceUI>

    /// Configure settings for an existing service.
    ///
    /// - Parameters:
    ///     - colorPalette: Color palette to use for any UI.
    /// - Returns: A view controller to configure an existing service.
    func settingsViewController(colorPalette: LoopUIColorPalette) -> ServiceViewController
}

public extension ServiceUI {
    var image: UIImage? { type(of: self).image }
}

public protocol ServiceOnboardingDelegate: AnyObject {
    /// Informs the delegate that the specified service was created.
    ///
    /// - Parameters:
    ///     - service: The service created.
    func serviceOnboarding(didCreateService service: Service)

    /// Informs the delegate that the specified service was onboarded.
    ///
    /// - Parameters:
    ///     - service: The service onboarded.
    func serviceOnboarding(didOnboardService service: Service)
}

public protocol ServiceOnboarding {
    /// Delegate to notify about service onboarding.
    var serviceOnboardingDelegate: ServiceOnboardingDelegate? { get set }
}
