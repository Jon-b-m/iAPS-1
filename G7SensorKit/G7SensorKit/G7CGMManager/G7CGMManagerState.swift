import Foundation
import LoopKit

public struct G7CGMManagerState: RawRepresentable, Equatable {
    public typealias RawValue = CGMManager.RawStateValue

    public var sensorID: String?
    public var activatedAt: Date?
    public var latestReading: G7GlucoseMessage?
    public var latestReadingTimestamp: Date?
    public var latestConnect: Date?
    public var uploadReadings: Bool = true

    init() {}

    public init(rawValue: RawValue) {
        sensorID = rawValue["sensorID"] as? String
        activatedAt = rawValue["activatedAt"] as? Date
        if let readingData = rawValue["latestReading"] as? Data {
            latestReading = G7GlucoseMessage(data: readingData)
        }
        latestReadingTimestamp = rawValue["latestReadingTimestamp"] as? Date
        latestConnect = rawValue["latestConnect"] as? Date
        uploadReadings = rawValue["uploadReadings"] as? Bool ?? true
    }

    public var rawValue: RawValue {
        var rawValue: RawValue = [:]
        rawValue["sensorID"] = sensorID
        rawValue["activatedAt"] = activatedAt
        rawValue["latestReading"] = latestReading?.data
        rawValue["latestReadingTimestamp"] = latestReadingTimestamp
        rawValue["latestConnect"] = latestConnect
        rawValue["uploadReadings"] = uploadReadings
        return rawValue
    }
}
