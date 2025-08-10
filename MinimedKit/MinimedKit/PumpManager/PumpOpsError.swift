import Foundation
import RileyLinkBLEKit

/// An error that occurs during a command run
///
/// - command: The error took place during the command sequence
/// - arguments: The error took place during the argument sequence
public enum PumpCommandError: Error {
    case command(PumpOpsError)
    case arguments(PumpOpsError)
}

public enum PumpOpsError: Error {
    case bolusInProgress
    case couldNotDecode(rx: Data, during: CustomStringConvertible)
    case crosstalk(PumpMessage, during: CustomStringConvertible)
    case deviceError(LocalizedError)
    case noResponse(during: CustomStringConvertible)
    case pumpError(PumpErrorCode)
    case pumpSuspended
    case rfCommsFailure(String)
    case unexpectedResponse(PumpMessage, from: PumpMessage)
    case unknownPumpErrorCode(UInt8)
    case unknownPumpModel(String)
    case unknownResponse(rx: Data, during: CustomStringConvertible)
}

extension PumpOpsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .bolusInProgress:
            return LocalizedString(
                "A bolus is already in progress",
                comment: "Communications error for a bolus currently running"
            )
        case let .couldNotDecode(rx: data, during: during):
            return String(
                format: LocalizedString(
                    "Invalid response during %1$@: %2$@",
                    comment: "Format string for failure reason. (1: The operation being performed) (2: The response data)"
                ),
                String(describing: during),
                data.hexadecimalString
            )
        case .crosstalk:
            return LocalizedString("Comms with another pump detected", comment: "Description for PumpOpsError.crosstalk")
        case .noResponse:
            return LocalizedString("Pump did not respond", comment: "Description for PumpOpsError.noResponse")
        case .pumpSuspended:
            return LocalizedString("Pump is suspended", comment: "Description for PumpOpsError.pumpSuspended")
        case let .rfCommsFailure(msg):
            return msg
        case let .unexpectedResponse(response, _):
            return String(
                format: LocalizedString(
                    "Unexpected response %1$@",
                    comment: "Format string for an unexpectedResponse. (2: The response)"
                ),
                String(describing: response)
            )
        case let .unknownPumpErrorCode(code):
            return String(
                format: LocalizedString(
                    "Unknown pump error code: %1$@",
                    comment: "The format string description of an unknown pump error code. (1: The specific error code raw value)"
                ),
                String(describing: code)
            )
        case let .unknownPumpModel(model):
            return String(format: LocalizedString("Unknown pump model: %@", comment: ""), model)
        case let .unknownResponse(rx: data, during: during):
            return String(
                format: LocalizedString(
                    "Unknown response during %1$@: %2$@",
                    comment: "Format string for an unknown response. (1: The operation being performed) (2: The response data)"
                ),
                String(describing: during),
                data.hexadecimalString
            )
        case let .pumpError(errorCode):
            return String(describing: errorCode)
        case let .deviceError(error):
            return [error.errorDescription, error.failureReason].compactMap({ $0 }).joined(separator: ": ")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .pumpError(errorCode):
            return errorCode.recoverySuggestion
        case let .deviceError(error):
            return error.recoverySuggestion
        default:
            return nil
        }
    }

    public var helpAnchor: String? {
        switch self {
        case let .deviceError(error):
            return error.helpAnchor
        default:
            return nil
        }
    }
}

extension PumpCommandError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .arguments(error):
            return error.errorDescription
        case let .command(error):
            return error.errorDescription
        }
    }

    public var failureReason: String? {
        switch self {
        case let .arguments(error):
            return error.failureReason
        case let .command(error):
            return error.failureReason
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .arguments(error):
            return error.recoverySuggestion
        case let .command(error):
            return error.recoverySuggestion
        }
    }

    public var helpAnchor: String? {
        switch self {
        case let .arguments(error):
            return error.helpAnchor
        case let .command(error):
            return error.helpAnchor
        }
    }
}
