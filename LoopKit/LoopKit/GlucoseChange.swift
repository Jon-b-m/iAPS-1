import HealthKit

public struct GlucoseChange: SampleValue, Equatable {
    public var startDate: Date
    public var endDate: Date
    public var quantity: HKQuantity
}

public extension GlucoseChange {
    mutating func append(_ effect: GlucoseEffect) {
        startDate = min(effect.startDate, startDate)
        endDate = max(effect.endDate, endDate)
        quantity = HKQuantity(
            unit: .milligramsPerDeciliter,
            doubleValue: quantity.doubleValue(for: .milligramsPerDeciliter) + effect.quantity
                .doubleValue(for: .milligramsPerDeciliter)
        )
    }
}
