public enum RileyLinkDeviceError: Error {
    case peripheralManagerError(LocalizedError)
    case errorResponse(String)
    case writeSizeLimitExceeded(maxLength: Int)
    case invalidResponse(Data)
    case responseTimeout
    case commandsBlocked
    case unsupportedCommand(String)
}

extension RileyLinkDeviceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .peripheralManagerError(error):
            return error.errorDescription
        case let .errorResponse(message):
            return message
        case let .invalidResponse(response):
            return String(
                format: LocalizedString("Response %@ is invalid", comment: "Invalid response error description (1: response)"),
                String(describing: response)
            )
        case let .writeSizeLimitExceeded(maxLength):
            return String(
                format: LocalizedString(
                    "Data exceeded maximum size of %@ bytes",
                    comment: "Write size limit exceeded error description (1: size limit)"
                ),
                NumberFormatter.localizedString(from: NSNumber(value: maxLength), number: .none)
            )
        case .responseTimeout:
            return LocalizedString("Pump did not respond in time", comment: "Response timeout error description")
        case .commandsBlocked:
            return LocalizedString("RileyLink command did not respond", comment: "commandsBlocked error description")
        case let .unsupportedCommand(command):
            return String(
                format: LocalizedString(
                    "RileyLink firmware does not support the %@ command",
                    comment: "Unsupported command error description"
                ),
                String(describing: command)
            )
        }
    }

    public var failureReason: String? {
        switch self {
        case let .peripheralManagerError(error):
            return error.failureReason
        default:
            return nil
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .peripheralManagerError(error):
            return error.recoverySuggestion
        case .commandsBlocked:
            return LocalizedString(
                "RileyLink may need to be turned off and back on",
                comment: "commandsBlocked recovery suggestion"
            )
        default:
            return nil
        }
    }
}
