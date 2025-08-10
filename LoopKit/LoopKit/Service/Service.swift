public protocol PluginHost {
    /// An identifier for the host (app) of this service. Should something that uniquely identifies the app. Example: "com.loopkit.Loop", or "org.tidepool.Loop"
    var hostIdentifier: String { get }

    /// The version of the host of this service.
    var hostVersion: String { get }
}

public protocol ServiceDelegate: PluginHost, AlertIssuer, RemoteActionDelegate {}

public protocol Service: StatefulPluggable {
    /// The localized title of this type of plugin.
    static var localizedTitle: String { get }

    var serviceDelegate: ServiceDelegate? { get set }
}

public extension Service {
    var localizedTitle: String { type(of: self).localizedTitle }
}
