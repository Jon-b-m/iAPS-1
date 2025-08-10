import Foundation

public struct SensorStatusGlucoseEvent: GlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents
    private let statusType: String

    public init?(availableData: Data, relativeTimestamp _: DateComponents) {
        length = 5

        guard length <= availableData.count else {
            return nil
        }

        func d(_ idx: Int) -> Int {
            Int(availableData[idx])
        }

        rawData = availableData.subdata(in: 0 ..< length)
        timestamp = DateComponents(glucoseEventBytes: availableData.subdata(in: 1 ..< 5))

        switch d(3) >> 5 & 0b0000_0011 {
        case 0x00:
            statusType = "off"
        case 0x01:
            statusType = "on"
        case 0x02:
            statusType = "lost"
        default:
            statusType = "unknown"
        }
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "SensorStatus",
            "statusType": statusType
        ]
    }
}
