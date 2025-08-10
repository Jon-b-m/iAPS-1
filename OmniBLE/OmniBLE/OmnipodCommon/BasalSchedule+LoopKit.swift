import Foundation
import LoopKit

public extension BasalSchedule {
    init(repeatingScheduleValues: [LoopKit.RepeatingScheduleValue<Double>]) {
        self.init(entries: repeatingScheduleValues.map { BasalScheduleEntry(rate: $0.value, startTime: $0.startTime) })
    }
}
