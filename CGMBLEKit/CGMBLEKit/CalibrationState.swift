import Foundation

public enum CalibrationState: RawRepresentable {
    public typealias RawValue = UInt8

    public enum State: RawValue {
        case stopped = 1
        case warmup = 2

        case needFirstInitialCalibration = 4
        case needSecondInitialCalibration = 5
        case ok = 6
        case needCalibration7 = 7
        case calibrationError8 = 8
        case calibrationError9 = 9
        case calibrationError10 = 10
        case sensorFailure11 = 11
        case sensorFailure12 = 12
        case calibrationError13 = 13
        case needCalibration14 = 14
        case sessionFailure15 = 15
        case sessionFailure16 = 16
        case sessionFailure17 = 17
        case questionMarks = 18
    }

    case known(State)
    case unknown(RawValue)

    public init(rawValue: RawValue) {
        guard let state = State(rawValue: rawValue) else {
            self = .unknown(rawValue)
            return
        }

        self = .known(state)
    }

    public var rawValue: RawValue {
        switch self {
        case let .known(state):
            return state.rawValue
        case let .unknown(rawValue):
            return rawValue
        }
    }

    public var hasReliableGlucose: Bool {
        guard case let .known(state) = self else {
            return false
        }

        switch state {
        case .calibrationError8,
             .calibrationError9,
             .calibrationError10,
             .calibrationError13,
             .needFirstInitialCalibration,
             .needSecondInitialCalibration,
             .questionMarks,
             .sensorFailure11,
             .sensorFailure12,
             .sessionFailure15,
             .sessionFailure16,
             .sessionFailure17,
             .stopped,
             .warmup:
            return false
        case .needCalibration7,
             .needCalibration14,
             .ok:
            return true
        }
    }
}

extension CalibrationState: Equatable {
    public static func == (lhs: CalibrationState, rhs: CalibrationState) -> Bool {
        switch (lhs, rhs) {
        case let (.known(lhs), .known(rhs)):
            return lhs == rhs
        case let (.unknown(lhs), .unknown(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension CalibrationState: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .known(state):
            return String(describing: state)
        case let .unknown(value):
            return ".unknown(\(value))"
        }
    }
}
