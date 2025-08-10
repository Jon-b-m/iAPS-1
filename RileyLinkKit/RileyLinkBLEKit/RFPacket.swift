import Foundation

public struct RFPacket: CustomStringConvertible {
    public let data: Data
    let packetCounter: Int
    public let rssi: Int

    public init?(rfspyResponse: Data) {
        guard rfspyResponse.count >= 2 else {
            return nil
        }

        let startIndex = rfspyResponse.startIndex

        let rssiDec = Int(rfspyResponse[startIndex])
        let rssiOffset = 73
        if rssiDec >= 128 {
            rssi = (rssiDec - 256) / 2 - rssiOffset
        } else {
            rssi = rssiDec / 2 - rssiOffset
        }

        packetCounter = Int(rfspyResponse[startIndex.advanced(by: 1)])

        data = rfspyResponse.subdata(in: startIndex.advanced(by: 2) ..< rfspyResponse.endIndex)
    }

    public var description: String {
        String(
            format: "RFPacket(%1$@, %2$@, %3$@)",
            String(describing: rssi),
            String(describing: packetCounter),
            data.hexadecimalString
        )
    }
}
