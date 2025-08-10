import Foundation
import HealthKit
import LoopKit

enum GlucoseLimits {
    static var minimum: UInt16 = 40
    static var maximum: UInt16 = 400
}

extension ShareGlucose: GlucoseValue {
    public var startDate: Date {
        timestamp
    }

    public var quantity: HKQuantity {
        HKQuantity(
            unit: .milligramsPerDeciliter,
            doubleValue: Double(min(max(glucose, GlucoseLimits.minimum), GlucoseLimits.maximum))
        )
    }
}

extension ShareGlucose: GlucoseDisplayable {
    public var isStateValid: Bool {
        glucose >= 39
    }

    public var trendType: GlucoseTrend? {
        GlucoseTrend(rawValue: Int(trend))
    }

    public var trendRate: HKQuantity? {
        nil
    }

    public var isLocal: Bool {
        false
    }

    // TODO: Placeholder. This functionality will come with LOOP-1311
    public var glucoseRangeCategory: GlucoseRangeCategory? {
        nil
    }
}

public extension ShareGlucose {
    var condition: GlucoseCondition? {
        if glucose < GlucoseLimits.minimum {
            return .belowRange
        } else if glucose > GlucoseLimits.maximum {
            return .aboveRange
        } else {
            return nil
        }
    }
}

public extension GlucoseDisplayable {
    var stateDescription: String {
        if isStateValid {
            return LocalizedString("OK", comment: "Sensor state description for the valid state")
        } else {
            return LocalizedString("Needs Attention", comment: "Sensor state description for the non-valid state")
        }
    }
}
