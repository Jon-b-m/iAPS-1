import Foundation

public struct MinimedPacket {
    public let data: Data

    public init(outgoingData: Data) {
        data = outgoingData
    }

    public init?(encodedData: Data) {
        if let decoded = encodedData.decode4b6b() {
            if decoded.isEmpty {
                return nil
            }
            let msg = decoded.prefix(upTo: decoded.count - 1)
            if decoded.last != msg.crc8() {
                // CRC invalid
                return nil
            }
            data = Data(msg)
        } else {
            // Could not decode message
            return nil
        }
    }

    public func encodedData() -> Data {
        var dataWithCRC = data
        dataWithCRC.append(data.crc8())
        var encodedData = dataWithCRC.encode4b6b()
        encodedData.append(0)
        return Data(encodedData)
    }
}
