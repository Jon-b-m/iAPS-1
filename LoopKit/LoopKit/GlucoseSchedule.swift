import Foundation
import HealthKit

public typealias InsulinSensitivitySchedule = SingleQuantitySchedule

public extension InsulinSensitivitySchedule {
    private func convertTo(unit: HKUnit) -> InsulinSensitivitySchedule? {
        guard unit != self.unit else {
            return self
        }

        let convertedDailyItems: [RepeatingScheduleValue<Double>] = items.map {
            RepeatingScheduleValue(
                startTime: $0.startTime,
                value: HKQuantity(unit: self.unit, doubleValue: $0.value)
                    .doubleValue(for: unit, withRounding: true)
            )
        }

        return InsulinSensitivitySchedule(
            unit: unit,
            dailyItems: convertedDailyItems,
            timeZone: timeZone
        )
    }

    func schedule(for glucoseUnit: HKUnit) -> InsulinSensitivitySchedule? {
        // InsulinSensitivitySchedule stores only the glucose unit.
        precondition(glucoseUnit == .millimolesPerLiter || glucoseUnit == .milligramsPerDeciliter)
        return convertTo(unit: glucoseUnit)
    }

    func value(for glucoseUnit: HKUnit, at time: Date) -> Double {
        let unconvertedValue = value(at: time)
        return HKQuantity(unit: unit, doubleValue: unconvertedValue).doubleValue(for: glucoseUnit, withRounding: true)
    }
}
