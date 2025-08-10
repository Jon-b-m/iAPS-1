public typealias CarbSensitivitySchedule = SingleQuantitySchedule

public extension /* CarbSensitivitySchedule */ DailyQuantitySchedule where T == Double {
    static func carbSensitivitySchedule(
        insulinSensitivitySchedule: InsulinSensitivitySchedule,
        carbRatioSchedule: CarbRatioSchedule
    ) -> CarbSensitivitySchedule {
        insulinSensitivitySchedule / carbRatioSchedule
    }
}
