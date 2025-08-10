import Foundation

public struct DeviceLinkMessageBody: DecodableMessageBody {
    public static let length = 5

    public let deviceAddress: Data
    public let sequence: UInt8
    public var txData: Data

    public init?(rxData: Data) {
        txData = rxData

        if rxData.count == type(of: self).length {
            deviceAddress = rxData.subdata(in: 1 ..< 4)
            sequence = rxData[0] & 0b1111111
        } else {
            return nil
        }
    }

    public var description: String {
        "DeviceLink(\(deviceAddress.hexadecimalString), \(sequence))"
    }
}
