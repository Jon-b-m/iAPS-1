import Foundation

/// A general set of ways insulin can be delivered by a pump
public enum DoseType: String, CaseIterable {
    case basal
    case bolus
    case resume
    case suspend
    case tempBasal

    public var localizedDescription: String {
        switch self {
        case .basal:
            return LocalizedString("Basal", comment: "Title for basal dose type")
        case .bolus:
            return LocalizedString("Bolus", comment: "Title for bolus dose type")
        case .tempBasal:
            return LocalizedString("Temp Basal", comment: "Title for temp basal dose type")
        case .suspend:
            return LocalizedString("Suspended", comment: "Title for suspend dose type")
        case .resume:
            return LocalizedString("Resumed", comment: "Title for resume dose type")
        }
    }
}

extension DoseType: Codable {}

/// Compatibility transform to PumpEventType
public extension DoseType {
    init?(pumpEventType: PumpEventType) {
        switch pumpEventType {
        case .basal:
            self = .basal
        case .bolus:
            self = .bolus
        case .resume:
            self = .resume
        case .suspend:
            self = .suspend
        case .tempBasal:
            self = .tempBasal
        case .alarm,
             .alarmClear,
             .prime,
             .replaceComponent,
             .rewind:
            return nil
        }
    }

    var pumpEventType: PumpEventType {
        switch self {
        case .basal:
            return .basal
        case .bolus:
            return .bolus
        case .resume:
            return .resume
        case .suspend:
            return .suspend
        case .tempBasal:
            return .tempBasal
        }
    }
}
