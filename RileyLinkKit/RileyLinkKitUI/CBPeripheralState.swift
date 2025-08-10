import CoreBluetooth

public extension CBPeripheralState {
    // MARK: - CustomStringConvertible

    var description: String {
        switch self {
        case .connected:
            return LocalizedString("Connected", comment: "The connected state")
        case .connecting:
            return LocalizedString("Connecting", comment: "The in-progress connecting state")
        case .disconnected:
            return LocalizedString("Disconnected", comment: "The disconnected state")
        case .disconnecting:
            return LocalizedString("Disconnecting", comment: "The in-progress disconnecting state")
        @unknown default:
            return "Unknown: \(rawValue)"
        }
    }
}
