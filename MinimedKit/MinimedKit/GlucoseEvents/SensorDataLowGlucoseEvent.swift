import Foundation

public struct SensorDataLowGlucoseEvent: SensorValueGlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let sgv: Int
    public let timestamp: DateComponents

    public init?(availableData: Data, relativeTimestamp: DateComponents) {
        length = 1

        guard length <= availableData.count else {
            return nil
        }

        rawData = availableData.subdata(in: 0 ..< length)
        sgv = 40
        timestamp = relativeTimestamp
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "SensorDataLow",
            "sgv": sgv
        ]
    }
}
