import Foundation

public struct SensorSyncGlucoseEvent: GlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents
    private let syncType: String

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
        case 0x01:
            syncType = "new"
        case 0x02:
            syncType = "old"
        default:
            syncType = "find"
        }
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "SensorSync",
            "syncType": syncType
        ]
    }
}
