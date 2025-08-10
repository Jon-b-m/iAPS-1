import Foundation

public protocol GlucoseEvent: DictionaryRepresentable {
    init?(availableData: Data, relativeTimestamp: DateComponents)

    var rawData: Data {
        get
    }

    var length: Int {
        get
    }

    var timestamp: DateComponents {
        get
    }
}
