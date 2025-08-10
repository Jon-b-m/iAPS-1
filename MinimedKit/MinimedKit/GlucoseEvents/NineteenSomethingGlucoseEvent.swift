import Foundation

public struct NineteenSomethingGlucoseEvent: GlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents

    public init?(availableData: Data, relativeTimestamp: DateComponents) {
        length = 1

        guard length <= availableData.count else {
            return nil
        }

        rawData = availableData.subdata(in: 0 ..< length)
        timestamp = relativeTimestamp
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "name": "19-Something"
        ]
    }
}
