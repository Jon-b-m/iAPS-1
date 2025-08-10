import Foundation
import HealthKit
import LoopKit

struct EnliteSensorDisplayable: Equatable, GlucoseDisplayable {
    public let isStateValid: Bool
    public let trendType: LoopKit.GlucoseTrend?
    public let trendRate: HKQuantity?
    public let isLocal: Bool

    // TODO: Placeholder. This functionality will come with LOOP-1311
    var glucoseRangeCategory: GlucoseRangeCategory? {
        nil
    }

    var glucoseCondition: GlucoseCondition? {
        nil
    }

    public init(_ event: MinimedKit.RelativeTimestampedGlucoseEvent) {
        isStateValid = event.isStateValid
        trendType = event.trendType
        trendRate = event.trendRate
        isLocal = event.isLocal
    }

    public init(_ status: MySentryPumpStatusMessageBody) {
        isStateValid = status.isStateValid
        trendType = status.trendType
        trendRate = nil
        isLocal = status.isLocal
    }
}

extension MinimedKit.RelativeTimestampedGlucoseEvent {
    var isStateValid: Bool {
        self is SensorValueGlucoseEvent
    }

    var trendType: LoopKit.GlucoseTrend? {
        nil
    }

    var trendRate: HKQuantity? {
        nil
    }

    var isLocal: Bool {
        true
    }
}
