import Foundation
import HealthKit

public extension GlucoseRangeSchedule {
    func safeSchedule(with suspendThreshold: HKQuantity?) -> GlucoseRangeSchedule? {
        let minGlucoseValue = [
            suspendThreshold?.doubleValue(for: unit),
            Guardrail.correctionRange.absoluteBounds.lowerBound.doubleValue(for: unit)
        ]
        .compactMap({ $0 })
        .max()!

        let maxGlucoseValue = Guardrail.correctionRange.absoluteBounds.upperBound.doubleValue(for: unit)

        func safeGlucoseValue(_ initialValue: Double) -> Double {
            max(minGlucoseValue, min(maxGlucoseValue, initialValue))
        }

        let filteredItems = rangeSchedule.valueSchedule.items.map { scheduleValue in
            let newScheduleValue = DoubleRange(
                minValue: safeGlucoseValue(scheduleValue.value.minValue),
                maxValue: safeGlucoseValue(scheduleValue.value.maxValue)
            )
            return RepeatingScheduleValue(startTime: scheduleValue.startTime, value: newScheduleValue)
        }
        guard let filteredRangeSchedule = DailyQuantitySchedule(unit: rangeSchedule.unit, dailyItems: filteredItems) else {
            return nil
        }
        return GlucoseRangeSchedule(rangeSchedule: filteredRangeSchedule, override: override)
    }
}
