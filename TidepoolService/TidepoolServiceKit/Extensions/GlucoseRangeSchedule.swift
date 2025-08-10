import HealthKit
import LoopKit

extension GlucoseRangeSchedule {
    func items(for unit: HKUnit) -> [RepeatingScheduleValue<DoubleRange>] {
        guard unit != self.unit else {
            return items
        }
        return items
            .map {
                RepeatingScheduleValue<DoubleRange>(
                    startTime: $0.startTime,
                    value: $0.value.converted(from: self.unit, to: unit)
                ) }
    }
}
