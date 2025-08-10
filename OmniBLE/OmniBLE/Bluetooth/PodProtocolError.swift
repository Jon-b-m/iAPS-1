import CoreBluetooth
import Foundation

enum PodProtocolError: Error {
    case invalidLTKKey(_ message: String)
    case pairingException(_ message: String)
    case messageIOException(_ message: String)
    case couldNotParseMessageException(_ message: String)
    case incorrectPacketException(_ payload: Data, _ location: Int)
    case invalidCrc(payloadCrc: Data, computedCrc: Data)
}

extension PodProtocolError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidLTKKey(message):
            return String(
                format: LocalizedString(
                    "Invalid LTK Key: %1$@",
                    comment: "The format string for PodProtocolError.invalidLTKKey (1: message associated with error)"
                ),
                message
            )
        case let .pairingException(message):
            return String(
                format: LocalizedString(
                    "Pairing Exception: %1$@",
                    comment: "The format string for PodProtocolError.pairingException (1: message associated with error)"
                ),
                message
            )
        case let .messageIOException(message):
            return String(
                format: LocalizedString(
                    "Message IO Exception: %1$@",
                    comment: "The format string for PodProtocolError.messageIOException (1: message associated with error)"
                ),
                message
            )
        case let .couldNotParseMessageException(message):
            return String(
                format: LocalizedString(
                    "Could not parse message: %1$@",
                    comment: "The format string for PodProtocolError.couldNotParseMessageException (1: message associated with error)"
                ),
                message
            )
        case let .incorrectPacketException(payload, location):
            let payloadStr = payload.hexadecimalString
            return String(
                format: LocalizedString(
                    "Incorrect Packet Exception: %1$@ (location=%2$d)",
                    comment: "The format string for PodProtocolError.incorrectPacketException (1: payload)(2: location)"
                ),
                payloadStr,
                location
            )
        case let .invalidCrc(payloadCrc, computedCrc):
            return String(
                format: LocalizedString(
                    "Payload crc32 %1$@ does not match computed crc32 %2$@",
                    comment: "The format string for description of PodProtocolError.invalidCrc (1:payload crc)(2:computed crc)"
                ),
                payloadCrc.hexadecimalString,
                computedCrc.hexadecimalString
            )
        }
    }

    public var failureReason: String? {
        nil
    }

    public var recoverySuggestion: String? {
        nil
    }
}
