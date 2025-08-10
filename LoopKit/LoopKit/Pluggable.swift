public protocol Pluggable: AnyObject {
    /// The unique identifier for this plugin.
    static var pluginIdentifier: String { get }

    /// A plugin may need a reference to another plugin. This callback allows for such a reference.
    /// It is called once during app initialization after plugins are initialized and again as new plugins are added and initialized.
    func initializationComplete(for pluggables: [Pluggable])
}

public extension Pluggable {
    var pluginIdentifier: String { type(of: self).pluginIdentifier }

    func initializationComplete(for _: [Pluggable]) {} // optional
}
