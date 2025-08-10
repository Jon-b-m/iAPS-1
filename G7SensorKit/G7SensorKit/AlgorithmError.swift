import Foundation

enum AlgorithmError: Error {
    case unreliableState(AlgorithmState)
}

extension AlgorithmError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unreliableState:
            return LocalizedString("Glucose data is unavailable", comment: "Error description for unreliable state")
        }
    }

    var failureReason: String? {
        switch self {
        case let .unreliableState(state):
            return state.localizedDescription
        }
    }
}

public extension AlgorithmState {
    var localizedDescription: String {
        switch self {
        case let .known(state):
            switch state {
            case .ok:
                return LocalizedString("Sensor is OK", comment: "The description of sensor algorithm state when sensor is ok.")
            case .stopped:
                return LocalizedString(
                    "Sensor is stopped",
                    comment: "The description of sensor algorithm state when sensor is stopped."
                )
            case .temporarySensorIssue,
                 .warmup:
                return LocalizedString(
                    "Sensor is warming up",
                    comment: "The description of sensor algorithm state when sensor is warming up."
                )
            case .expired:
                return LocalizedString(
                    "Sensor expired",
                    comment: "The description of sensor algorithm state when sensor is expired."
                )
            case .sensorFailed:
                return LocalizedString("Sensor failed", comment: "The description of sensor algorithm state when sensor failed.")
            default:
                return "Sensor state: \(String(describing: state))"
            }
        case let .unknown(rawValue):
            return String(
                format: LocalizedString(
                    "Sensor is in unknown state %1$d",
                    comment: "The description of sensor algorithm state when raw value is unknown. (1: missing data details)"
                ),
                rawValue
            )
        }
    }
}
