import HealthKit

public protocol GlucoseSampleValue: GlucoseValue {
    /// Uniquely identifies the source of the sample.
    var provenanceIdentifier: String { get }

    /// Whether the glucose value was provided for visual consistency, rather than an actual, calibrated reading.
    var isDisplayOnly: Bool { get }

    /// Whether the glucose value was entered by the user.
    var wasUserEntered: Bool { get }

    /// Any condition applied to the sample.
    var condition: GlucoseCondition? { get }

    /// The trend of the sample.
    var trend: GlucoseTrend? { get }

    /// The trend rate of the sample.
    var trendRate: HKQuantity? { get }

    /// The syncIdentifier of the sample.
    var syncIdentifier: String? { get }
}
