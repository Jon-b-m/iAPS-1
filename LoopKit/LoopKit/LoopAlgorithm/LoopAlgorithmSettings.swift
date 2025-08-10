import Foundation
import HealthKit

public struct LoopAlgorithmSettings {
    // Algorithm input time range: t-16h to t
    public var basal: [AbsoluteScheduleValue<Double>]

    // Algorithm input time range: t-16h to t (eventually with mid-absorption isf changes, it will be t-10h to h)
    public var sensitivity: [AbsoluteScheduleValue<HKQuantity>]

    // Algorithm input time range: t-10h to t
    public var carbRatio: [AbsoluteScheduleValue<Double>]

    // Algorithm input time range: t to t+6
    public var target: [AbsoluteScheduleValue<ClosedRange<HKQuantity>>]

    public var delta: TimeInterval
    public var insulinActivityDuration: TimeInterval
    public var algorithmEffectsOptions: AlgorithmEffectsOptions
    public var maximumBasalRatePerHour: Double?
    public var maximumBolus: Double?
    public var suspendThreshold: GlucoseThreshold?
    public var useIntegralRetrospectiveCorrection: Bool = false

    public init(
        basal: [AbsoluteScheduleValue<Double>],
        sensitivity: [AbsoluteScheduleValue<HKQuantity>],
        carbRatio: [AbsoluteScheduleValue<Double>],
        target: [AbsoluteScheduleValue<ClosedRange<HKQuantity>>],
        delta: TimeInterval = GlucoseMath.defaultDelta,
        insulinActivityDuration: TimeInterval = InsulinMath.defaultInsulinActivityDuration,
        algorithmEffectsOptions: AlgorithmEffectsOptions = .all,
        maximumBasalRatePerHour: Double? = nil,
        maximumBolus: Double? = nil,
        suspendThreshold: GlucoseThreshold? = nil,
        useIntegralRetrospectiveCorrection: Bool = false
    )
    {
        self.basal = basal
        self.sensitivity = sensitivity
        self.carbRatio = carbRatio
        self.target = target
        self.delta = delta
        self.insulinActivityDuration = insulinActivityDuration
        self.algorithmEffectsOptions = algorithmEffectsOptions
        self.maximumBasalRatePerHour = maximumBasalRatePerHour
        self.maximumBolus = maximumBolus
        self.suspendThreshold = suspendThreshold
        self.useIntegralRetrospectiveCorrection = useIntegralRetrospectiveCorrection
    }
}

extension LoopAlgorithmSettings: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        basal = try container.decode([AbsoluteScheduleValue<Double>].self, forKey: .basal)
        let sensitivityMgdl = try container.decode([AbsoluteScheduleValue<Double>].self, forKey: .sensitivity)
        sensitivity = sensitivityMgdl.map { AbsoluteScheduleValue(
            startDate: $0.startDate,
            endDate: $0.endDate,
            value: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: $0.value)
        ) }
        carbRatio = try container.decode([AbsoluteScheduleValue<Double>].self, forKey: .carbRatio)
        let targetMgdl = try container.decode([AbsoluteScheduleValue<DoubleRange>].self, forKey: .target)
        target = targetMgdl.map {
            let min = HKQuantity(unit: .milligramsPerDeciliter, doubleValue: $0.value.minValue)
            let max = HKQuantity(unit: .milligramsPerDeciliter, doubleValue: $0.value.minValue)
            return AbsoluteScheduleValue(
                startDate: $0.startDate,
                endDate: $0.endDate,
                value: ClosedRange(uncheckedBounds: (lower: min, upper: max))
            )
        }
        delta = TimeInterval(minutes: 5)
        insulinActivityDuration = InsulinMath.defaultInsulinActivityDuration
        algorithmEffectsOptions = .all
        maximumBasalRatePerHour = try container.decodeIfPresent(Double.self, forKey: .maximumBasalRatePerHour)
        maximumBolus = try container.decodeIfPresent(Double.self, forKey: .maximumBolus)
        suspendThreshold = try container.decodeIfPresent(GlucoseThreshold.self, forKey: .suspendThreshold)
        useIntegralRetrospectiveCorrection = try container.decodeIfPresent(
            Bool.self,
            forKey: .useIntegralRetrospectiveCorrection
        ) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(basal, forKey: .basal)
        let sensitivityMgdl = sensitivity
            .map {
                AbsoluteScheduleValue(
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    value: $0.value.doubleValue(for: .milligramsPerDeciliter)
                ) }
        try container.encode(sensitivityMgdl, forKey: .sensitivity)
        try container.encode(carbRatio, forKey: .carbRatio)
        let targetMgdl = target.map {
            let min = $0.value.lowerBound.doubleValue(for: .milligramsPerDeciliter)
            let max = $0.value.upperBound.doubleValue(for: .milligramsPerDeciliter)
            return AbsoluteScheduleValue(
                startDate: $0.startDate,
                endDate: $0.endDate,
                value: DoubleRange(minValue: min, maxValue: max)
            )
        }
        try container.encode(targetMgdl, forKey: .target)
        try container.encode(maximumBasalRatePerHour, forKey: .maximumBasalRatePerHour)
        try container.encode(maximumBolus, forKey: .maximumBolus)
        try container.encode(suspendThreshold, forKey: .suspendThreshold)
        if useIntegralRetrospectiveCorrection {
            try container.encode(useIntegralRetrospectiveCorrection, forKey: .useIntegralRetrospectiveCorrection)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case basal
        case sensitivity
        case carbRatio
        case target
        case delta
        case insulinActivityDuration
        case algorithmEffectsOptions
        case maximumBasalRatePerHour
        case maximumBolus
        case suspendThreshold
        case useIntegralRetrospectiveCorrection
    }
}

extension LoopAlgorithmSettings {
    var simplifiedForFixture: LoopAlgorithmSettings {
        LoopAlgorithmSettings(
            basal: basal,
            sensitivity: sensitivity,
            carbRatio: carbRatio,
            target: target
        )
    }
}
