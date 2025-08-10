import Foundation

public enum TransmitterStatus {
    public typealias RawValue = UInt8

    case ok
    case lowBattery
    case unknown(RawValue)

    init(rawValue: RawValue) {
        switch rawValue {
        case 0:
            self = .ok
        case 0x81:
            self = .lowBattery
        default:
            self = .unknown(rawValue)
        }
    }
}

extension TransmitterStatus: Equatable {}

public func == (lhs: TransmitterStatus, rhs: TransmitterStatus) -> Bool {
    switch (lhs, rhs) {
    case (.lowBattery, .lowBattery),
         (.ok, .ok):
        return true
    case let (.unknown(left), .unknown(right)) where left == right:
        return true
    default:
        return false
    }
}

public extension TransmitterStatus {
    var localizedDescription: String {
        switch self {
        case .ok:
            return LocalizedString("OK", comment: "Describes a functioning transmitter")
        case .lowBattery:
            return LocalizedString("Low Battery", comment: "Describes a low battery")
        case let .unknown(value):
            return "TransmitterStatus.unknown(\(value))"
        }
    }
}
