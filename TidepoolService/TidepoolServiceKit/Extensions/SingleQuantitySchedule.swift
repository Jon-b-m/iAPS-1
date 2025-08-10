import HealthKit
import LoopKit

extension SingleQuantitySchedule {
    func items(for unit: HKUnit) -> [RepeatingScheduleValue<Double>] {
        guard unit != self.unit else {
            return items
        }
        return items
            .map { RepeatingScheduleValue<Double>(startTime: $0.startTime, value: $0.value.converted(from: self.unit, to: unit)) }
    }
}
