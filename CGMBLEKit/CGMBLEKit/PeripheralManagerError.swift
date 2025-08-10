import CoreBluetooth

enum PeripheralManagerError: Error {
    case cbPeripheralError(Error)
    case notReady
    case invalidConfiguration
    case timeout
    case unknownCharacteristic
}

extension PeripheralManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .cbPeripheralError(error):
            return error.localizedDescription
        case .notReady:
            return LocalizedString("Peripheral isnʼt connected", comment: "Not ready error description")
        case .invalidConfiguration:
            return LocalizedString("Peripheral command was invalid", comment: "invlid config error description")
        case .timeout:
            return LocalizedString("Peripheral did not respond in time", comment: "Timeout error description")
        case .unknownCharacteristic:
            return LocalizedString("Unknown characteristic", comment: "Error description")
        }
    }

    var failureReason: String? {
        switch self {
        case let .cbPeripheralError(error as NSError):
            return error.localizedFailureReason
        default:
            return errorDescription
        }
    }
}
