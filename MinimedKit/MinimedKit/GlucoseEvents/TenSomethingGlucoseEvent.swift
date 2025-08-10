import Foundation

public struct TenSomethingGlucoseEvent: GlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents

    public init?(availableData: Data, relativeTimestamp _: DateComponents) {
        length = 8

        guard length <= availableData.count else {
            return nil
        }

        rawData = availableData.subdata(in: 0 ..< length)
        timestamp = DateComponents(glucoseEventBytes: availableData.subdata(in: 1 ..< 5))
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "10-Something"
        ]
    }
}
