import Foundation

public struct SensorPacketGlucoseEvent: RelativeTimestampedGlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents
    private let packetType: String

    public init?(availableData: Data, relativeTimestamp: DateComponents) {
        length = 2

        guard length <= availableData.count else {
            return nil
        }

        func d(_ idx: Int) -> Int {
            Int(availableData[idx])
        }

        rawData = availableData.subdata(in: 0 ..< length)
        switch d(1) {
        case 0x02:
            packetType = "init"
        default:
            packetType = "unknown"
        }

        timestamp = relativeTimestamp
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "SensorPacket",
            "packetType": packetType
        ]
    }
}
