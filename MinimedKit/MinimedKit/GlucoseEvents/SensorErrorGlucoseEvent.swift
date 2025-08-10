import Foundation

public struct SensorErrorGlucoseEvent: RelativeTimestampedGlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents
    private let errorType: String

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
        case 0x01:
            errorType = "end"
        default:
            errorType = "unknown"
        }

        timestamp = relativeTimestamp
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "SensorErrorSignal",
            "errorType": errorType
        ]
    }
}
