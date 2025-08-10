public typealias EGPSchedule = SingleQuantitySchedule

public extension /* EGPSchedule */ DailyQuantitySchedule where T == Double {
    static func egpSchedule(
        basalSchedule: BasalRateSchedule,
        insulinSensitivitySchedule: InsulinSensitivitySchedule
    ) -> EGPSchedule {
        let basalScheduleWithUnit = DailyQuantitySchedule(unit: .internationalUnitsPerHour, valueSchedule: basalSchedule)
        return basalScheduleWithUnit * insulinSensitivitySchedule
    }
}
