import HealthKit
import LoopKit

struct DateRelativeGlucoseSample: DateRelativeQuantity, Codable {
    var mgdlValue: Double
    var dateOffset: TimeInterval

    var quantity: HKQuantity {
        HKQuantity(unit: .milligramsPerDeciliter, doubleValue: mgdlValue)
    }

    func newGlucoseSample(relativeTo referenceDate: Date) -> NewGlucoseSample {
        let date = referenceDate.addingTimeInterval(dateOffset)
        return NewGlucoseSample(
            date: date,
            quantity: quantity,
            condition: nil,
            trend: nil,
            trendRate: nil,
            isDisplayOnly: false,
            wasUserEntered: false,
            syncIdentifier: UUID().uuidString
        )
    }
}
