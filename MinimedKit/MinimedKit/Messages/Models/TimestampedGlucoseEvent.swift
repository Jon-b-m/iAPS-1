import Foundation

public struct TimestampedGlucoseEvent {
    public let glucoseEvent: GlucoseEvent
    public let date: Date

    public init(glucoseEvent: GlucoseEvent, date: Date) {
        self.glucoseEvent = glucoseEvent
        self.date = date
    }
}

extension TimestampedGlucoseEvent: DictionaryRepresentable {
    public var dictionaryRepresentation: [String: Any] {
        var dict = glucoseEvent.dictionaryRepresentation

        dict["timestamp"] = ISO8601DateFormatter.defaultFormatter().string(from: date)

        return dict
    }
}
