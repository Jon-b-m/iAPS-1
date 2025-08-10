import Foundation

public struct FindDeviceMessageBody: DecodableMessageBody {
    public static let length = 5

    public let deviceAddress: Data
    public let sequence: UInt8
    let rxData: Data

    public init?(rxData: Data) {
        self.rxData = rxData

        if rxData.count == type(of: self).length {
            deviceAddress = rxData.subdata(in: 1 ..< 4)
            sequence = rxData[0] & 0b1111111
        } else {
            return nil
        }
    }

    public var txData: Data {
        rxData
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "sequence": Int(sequence),
            "deviceAddress": deviceAddress.hexadecimalString
        ]
    }

    public var description: String {
        "FindDevice(\(deviceAddress.hexadecimalString), \(sequence))"
    }
}
