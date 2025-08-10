import Foundation

public struct RileyLinkConnectionState: RawRepresentable, Equatable {
    public typealias RawValue = RileyLinkDeviceProvider.RawStateValue

    public var autoConnectIDs: Set<String>

    public init(autoConnectIDs: Set<String>) {
        self.autoConnectIDs = autoConnectIDs
    }

    public init?(rawValue: RileyLinkDeviceProvider.RawStateValue) {
        guard
            let autoConnectIDs = rawValue["autoConnectIDs"] as? [String]
        else {
            return nil
        }

        self.init(autoConnectIDs: Set(autoConnectIDs))
    }

    public var rawValue: RawValue {
        [
            "autoConnectIDs": Array(autoConnectIDs)
        ]
    }
}
