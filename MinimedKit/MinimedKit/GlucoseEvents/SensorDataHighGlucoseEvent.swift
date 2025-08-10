import Foundation

public struct SensorDataHighGlucoseEvent: SensorValueGlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let sgv: Int
    public let timestamp: DateComponents

    public init?(availableData: Data, relativeTimestamp: DateComponents) {
        length = 2

        guard length <= availableData.count else {
            return nil
        }

        rawData = availableData.subdata(in: 0 ..< length)
        sgv = 400
        timestamp = relativeTimestamp
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "SensorDataHigh",
            "sgv": sgv
        ]
    }
}
