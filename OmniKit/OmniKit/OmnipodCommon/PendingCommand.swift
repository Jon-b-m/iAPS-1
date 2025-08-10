import Foundation
import LoopKit

public enum StartProgram: RawRepresentable {
    public typealias RawValue = [String: Any]

    case bolus(volume: Double, automatic: Bool)
    case basalProgram(schedule: BasalSchedule)
    case tempBasal(unitsPerHour: Double, duration: TimeInterval, isHighTemp: Bool, automatic: Bool)

    private enum StartProgramType: Int {
        case bolus
        case basalProgram
        case tempBasal
    }

    public var rawValue: RawValue {
        switch self {
        case let .bolus(volume, automatic):
            return [
                "programType": StartProgramType.bolus.rawValue,
                "volume": volume,
                "automatic": automatic
            ]
        case let .basalProgram(schedule):
            return [
                "programType": StartProgramType.basalProgram.rawValue,
                "schedule": schedule.rawValue
            ]
        case let .tempBasal(unitsPerHour, duration, isHighTemp, automatic):
            return [
                "programType": StartProgramType.tempBasal.rawValue,
                "unitsPerHour": unitsPerHour,
                "duration": duration,
                "isHighTemp": isHighTemp,
                "automatic": automatic
            ]
        }
    }

    public init?(rawValue: RawValue) {
        guard let encodedTypeRaw = rawValue["programType"] as? StartProgramType.RawValue,
              let encodedType = StartProgramType(rawValue: encodedTypeRaw)
        else {
            return nil
        }
        switch encodedType {
        case .bolus:
            guard let volume = rawValue["volume"] as? Double,
                  let automatic = rawValue["automatic"] as? Bool
            else {
                return nil
            }
            self = .bolus(volume: volume, automatic: automatic)
        case .basalProgram:
            guard let rawSchedule = rawValue["schedule"] as? BasalSchedule.RawValue,
                  let schedule = BasalSchedule(rawValue: rawSchedule)
            else {
                return nil
            }
            self = .basalProgram(schedule: schedule)
        case .tempBasal:
            guard let unitsPerHour = rawValue["unitsPerHour"] as? Double,
                  let duration = rawValue["duration"] as? TimeInterval,
                  let isHighTemp = rawValue["isHighTemp"] as? Bool
            else {
                return nil
            }
            let automatic = rawValue["automatic"] as? Bool ?? true
            self = .tempBasal(unitsPerHour: unitsPerHour, duration: duration, isHighTemp: isHighTemp, automatic: automatic)
        }
    }

    public static func == (lhs: StartProgram, rhs: StartProgram) -> Bool {
        switch (lhs, rhs) {
        case let (.bolus(lhsVolume, lhsAutomatic), .bolus(rhsVolume, rhsAutomatic)):
            return lhsVolume == rhsVolume && lhsAutomatic == rhsAutomatic
        case let (.basalProgram(lhsSchedule), .basalProgram(rhsSchedule)):
            return lhsSchedule == rhsSchedule
        case let (
            .tempBasal(lhsUnitsPerHour, lhsDuration, lhsIsHighTemp, lhsAutomatic),
            .tempBasal(rhsUnitsPerHour, rhsDuration, rhsIsHighTemp, rhsAutomatic)
        ):
            return lhsUnitsPerHour == rhsUnitsPerHour && lhsDuration == rhsDuration && lhsIsHighTemp == rhsIsHighTemp &&
                lhsAutomatic == rhsAutomatic
        default:
            return false
        }
    }
}

public enum PendingCommand: RawRepresentable, Equatable {
    public typealias RawValue = [String: Any]

    case program(StartProgram, Int, Date, Bool = true)
    case stopProgram(CancelDeliveryCommand.DeliveryType, Int, Date, Bool = true)

    private enum PendingCommandType: Int {
        case startProgram
        case stopProgram
    }

    public var commandDate: Date {
        switch self {
        case let .program(_, _, date, _):
            return date
        case let .stopProgram(_, _, date, _):
            return date
        }
    }

    public var sequence: Int {
        switch self {
        case let .program(_, sequence, _, _):
            return sequence
        case let .stopProgram(_, sequence, _, _):
            return sequence
        }
    }

    public var isInFlight: Bool {
        switch self {
        case let .program(_, _, _, inflight):
            return inflight
        case let .stopProgram(_, _, _, inflight):
            return inflight
        }
    }

    public var commsFinished: PendingCommand {
        switch self {
        case let .program(program, sequence, date, _):
            return PendingCommand.program(program, sequence, date, false)
        case let .stopProgram(program, sequence, date, _):
            return PendingCommand.stopProgram(program, sequence, date, false)
        }
    }

    public init?(rawValue: RawValue) {
        guard let rawPendingCommandType = rawValue["type"] as? PendingCommandType.RawValue else {
            return nil
        }

        guard let commandDate = rawValue["date"] as? Date else {
            return nil
        }

        guard let sequence = rawValue["sequence"] as? Int else {
            return nil
        }

        let inflight = rawValue["inflight"] as? Bool ?? false

        switch PendingCommandType(rawValue: rawPendingCommandType) {
        case .startProgram?:
            guard let rawUnacknowledgedProgram = rawValue["unacknowledgedProgram"] as? StartProgram.RawValue else {
                return nil
            }
            if let program = StartProgram(rawValue: rawUnacknowledgedProgram) {
                self = .program(program, sequence, commandDate, inflight)
            } else {
                return nil
            }
        case .stopProgram?:
            guard let rawDeliveryType = rawValue["unacknowledgedStopProgram"] as? CancelDeliveryCommand.DeliveryType.RawValue
            else {
                return nil
            }
            let stopProgram = CancelDeliveryCommand.DeliveryType(rawValue: rawDeliveryType)
            self = .stopProgram(stopProgram, sequence, commandDate, inflight)
        default:
            return nil
        }
    }

    public var rawValue: RawValue {
        var rawValue: RawValue = [:]

        switch self {
        case let .program(program, sequence, date, inflight):
            rawValue["type"] = PendingCommandType.startProgram.rawValue
            rawValue["date"] = date
            rawValue["sequence"] = sequence
            rawValue["inflight"] = inflight
            rawValue["unacknowledgedProgram"] = program.rawValue
        case let .stopProgram(stopProgram, sequence, date, inflight):
            rawValue["type"] = PendingCommandType.stopProgram.rawValue
            rawValue["date"] = date
            rawValue["sequence"] = sequence
            rawValue["inflight"] = inflight
            rawValue["unacknowledgedStopProgram"] = stopProgram.rawValue
        }
        return rawValue
    }

    public static func == (lhs: PendingCommand, rhs: PendingCommand) -> Bool {
        switch (lhs, rhs) {
        case let (
            .program(lhsProgram, lhsSequence, lhsDate, lhsInflight),
            .program(rhsProgram, rhsSequence, rhsDate, rhsInflight)
        ):
            return lhsProgram == rhsProgram && lhsSequence == rhsSequence && lhsDate == rhsDate && lhsInflight == rhsInflight
        case let (
            .stopProgram(lhsStopProgram, lhsSequence, lhsDate, lhsInflight),
            .stopProgram(rhsStopProgram, rhsSequence, rhsDate, rhsInflight)
        ):
            return lhsStopProgram == rhsStopProgram && lhsSequence == rhsSequence && lhsDate == rhsDate && lhsInflight ==
                rhsInflight
        default:
            return false
        }
    }
}
