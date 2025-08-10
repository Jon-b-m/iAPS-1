import Foundation

public struct PumpState: RawRepresentable, Equatable {
    public typealias RawValue = [String: Any]

    public var timeZone: TimeZone

    public var pumpModel: PumpModel?

    public var useMySentry: Bool

    public var awakeUntil: Date?

    public var lastValidFrequency: Measurement<UnitFrequency>?

    public var lastTuned: Date?

    var isAwake: Bool {
        if let awakeUntil = awakeUntil {
            return awakeUntil.timeIntervalSinceNow > 0
        }

        return false
    }

    var lastWakeAttempt: Date?

    public init() {
        timeZone = .currentFixed
        useMySentry = true
    }

    public init(timeZone: TimeZone, pumpModel: PumpModel, useMySentry: Bool) {
        self.timeZone = timeZone
        self.pumpModel = pumpModel
        self.useMySentry = useMySentry
    }

    public init?(rawValue: RawValue) {
        guard
            let timeZoneSeconds = rawValue["timeZone"] as? Int,
            let timeZone = TimeZone(secondsFromGMT: timeZoneSeconds)
        else {
            return nil
        }

        self.timeZone = timeZone
        useMySentry = rawValue["useMySentry"] as? Bool ?? true

        if let pumpModelNumber = rawValue["pumpModel"] as? PumpModel.RawValue {
            pumpModel = PumpModel(rawValue: pumpModelNumber)
        }

        if let frequencyRaw = rawValue["lastValidFrequency"] as? Double {
            lastValidFrequency = Measurement<UnitFrequency>(value: frequencyRaw, unit: .megahertz)
        }
    }

    public var rawValue: RawValue {
        var rawValue: RawValue = [
            "timeZone": timeZone.secondsFromGMT(),
            "useMySentry": useMySentry
        ]

        if let pumpModel = pumpModel {
            rawValue["pumpModel"] = pumpModel.rawValue
        }

        if let frequency = lastValidFrequency?.converted(to: .megahertz) {
            rawValue["lastValidFrequency"] = frequency.value
        }

        return rawValue
    }
}

extension PumpState: CustomDebugStringConvertible {
    public var debugDescription: String {
        [
            "## PumpState",
            "timeZone: \(timeZone)",
            "pumpModel: \(pumpModel?.rawValue ?? "")",
            "useMySentry: \(useMySentry)",
            "awakeUntil: \(awakeUntil ?? .distantPast)",
            "lastValidFrequency: \(String(describing: lastValidFrequency))",
            "lastTuned: \(awakeUntil ?? .distantPast))",
            "lastWakeAttempt: \(String(describing: lastWakeAttempt))"
        ].joined(separator: "\n")
    }
}
