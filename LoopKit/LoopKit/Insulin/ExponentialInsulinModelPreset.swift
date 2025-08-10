import Foundation

public enum ExponentialInsulinModelPreset: String, Codable {
    case rapidActingAdult
    case rapidActingChild
    case fiasp
    case lyumjev
    case afrezza
}

// MARK: - Model generation

public extension ExponentialInsulinModelPreset {
    var actionDuration: TimeInterval {
        switch self {
        case .rapidActingAdult:
            return .minutes(360)
        case .rapidActingChild:
            return .minutes(360)
        case .fiasp:
            return .minutes(360)
        case .lyumjev:
            return .minutes(360)
        case .afrezza:
            return .minutes(300)
        }
    }

    var peakActivity: TimeInterval {
        switch self {
        case .rapidActingAdult:
            return .minutes(75)
        case .rapidActingChild:
            return .minutes(65)
        case .fiasp:
            return .minutes(55)
        case .lyumjev:
            return .minutes(55)
        case .afrezza:
            return .minutes(29)
        }
    }

    var delay: TimeInterval {
        switch self {
        case .rapidActingAdult:
            return .minutes(10)
        case .rapidActingChild:
            return .minutes(10)
        case .fiasp:
            return .minutes(10)
        case .lyumjev:
            return .minutes(10)
        case .afrezza:
            return .minutes(10)
        }
    }

    internal var model: InsulinModel {
        ExponentialInsulinModel(actionDuration: actionDuration, peakActivityTime: peakActivity, delay: delay)
    }
}

extension ExponentialInsulinModelPreset: InsulinModel {
    public var effectDuration: TimeInterval {
        model.effectDuration
    }

    public func percentEffectRemaining(at time: TimeInterval) -> Double {
        model.percentEffectRemaining(at: time)
    }
}

extension ExponentialInsulinModelPreset: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(rawValue)(\(String(reflecting: model)))"
    }
}
