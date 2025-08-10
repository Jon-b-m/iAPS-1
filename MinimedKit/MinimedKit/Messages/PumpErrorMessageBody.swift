import Foundation

public enum PumpErrorCode: UInt8, CustomStringConvertible {
    // commandRefused can happen when temp basal type is set incorrectly, during suspended pump, or unfinished prime.
    case commandRefused = 0x08
    case maxSettingExceeded = 0x09
    case bolusInProgress = 0x0C
    case pageDoesNotExist = 0x0D

    public var description: String {
        switch self {
        case .commandRefused:
            return LocalizedString("Command refused", comment: "Pump error code returned when command refused")
        case .maxSettingExceeded:
            return LocalizedString("Max setting exceeded", comment: "Pump error code describing max setting exceeded")
        case .bolusInProgress:
            return LocalizedString("Bolus in progress", comment: "Pump error code when bolus is in progress")
        case .pageDoesNotExist:
            return LocalizedString(
                "History page does not exist",
                comment: "Pump error code when invalid history page is requested"
            )
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .commandRefused:
            return LocalizedString(
                "Check that the pump is not suspended or priming, or has a percent temp basal type",
                comment: "Suggestions for diagnosing a command refused pump error"
            )
        default:
            return nil
        }
    }
}

public class PumpErrorMessageBody: DecodableMessageBody {
    public static let length = 1

    let rxData: Data
    public let errorCode: PartialDecode<PumpErrorCode, UInt8>

    public required init?(rxData: Data) {
        self.rxData = rxData
        let rawErrorCode = rxData[0]
        if let errorCode = PumpErrorCode(rawValue: rawErrorCode) {
            self.errorCode = .known(errorCode)
        } else {
            errorCode = .unknown(rawErrorCode)
        }
    }

    public var txData: Data {
        rxData
    }

    public var description: String {
        "PumpError(\(errorCode))"
    }
}
