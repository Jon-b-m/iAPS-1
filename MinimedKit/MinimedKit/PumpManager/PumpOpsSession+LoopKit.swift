import Foundation
import LoopKit

public extension PumpOpsSession {
    func getBasalRateSchedule(for profile: BasalProfile) throws -> BasalRateSchedule? {
        let basalSchedule = try getBasalSchedule(for: profile)

        return BasalRateSchedule(dailyItems: basalSchedule?.entries.map(\.repeatingScheduleValue) ?? [], timeZone: pump.timeZone)
    }
}

public extension BasalSchedule {
    init(repeatingScheduleValues: [LoopKit.RepeatingScheduleValue<Double>]) {
        self.init(entries: repeatingScheduleValues.enumerated().map({ (index, value) -> BasalScheduleEntry in
            BasalScheduleEntry(index: index, repeatingScheduleValue: value)
        }))
    }
}

extension MinimedKit.BasalScheduleEntry {
    init(index: Int, repeatingScheduleValue: LoopKit.RepeatingScheduleValue<Double>) {
        self.init(index: index, timeOffset: repeatingScheduleValue.startTime, rate: repeatingScheduleValue.value)
    }

    var repeatingScheduleValue: LoopKit.RepeatingScheduleValue<Double> {
        RepeatingScheduleValue(startTime: timeOffset, value: rate)
    }
}
