import Foundation

public enum CgmEventType: String {
    case sensorStart
    case sensorEnd
    case transmitterStart
    case transmitterEnd
}

public struct PersistedCgmEvent {
    public var date: Date
    public var type: CgmEventType
    public var deviceIdentifier: String
    public var expectedLifetime: TimeInterval?
    public var warmupPeriod: TimeInterval?
    public var failureMessage: String?

    public init(
        date: Date,
        type: CgmEventType,
        deviceIdentifier: String,
        expectedLifetime: TimeInterval? = nil,
        warmupPeriod: TimeInterval? = nil,
        failureMessage: String? = nil
    ) {
        self.date = date
        self.type = type
        self.deviceIdentifier = deviceIdentifier
        self.expectedLifetime = expectedLifetime
        self.warmupPeriod = warmupPeriod
        self.failureMessage = failureMessage
    }
}

extension PersistedCgmEvent {
    init?(managedObject: CgmEvent) {
        guard let type = managedObject.type else {
            return nil
        }
        self.init(
            date: managedObject.date,
            type: type,
            deviceIdentifier: managedObject.deviceIdentifier,
            expectedLifetime: managedObject.expectedLifetime,
            warmupPeriod: managedObject.warmupPeriod,
            failureMessage: managedObject.failureMessage
        )
    }
}

extension CgmEvent {
    var persistedCgmEvent: PersistedCgmEvent? {
        PersistedCgmEvent(managedObject: self)
    }
}
