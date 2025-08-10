import Foundation
import HealthKit
import LoopKit

struct InsulinSensitivityScheduleEditorViewModel {
    let insulinSensitivitySchedule: InsulinSensitivitySchedule?

    var saveInsulinSensitivitySchedule: (_ insulinSensitivitySchedule: InsulinSensitivitySchedule) -> Void

    init(
        therapySettingsViewModel: TherapySettingsViewModel,
        didSave: (() -> Void)? = nil
    )
    {
        insulinSensitivitySchedule = therapySettingsViewModel.insulinSensitivitySchedule
        saveInsulinSensitivitySchedule = { [weak therapySettingsViewModel] insulinSensitivitySchedule in
            guard let therapySettingsViewModel = therapySettingsViewModel else {
                return
            }

            therapySettingsViewModel.saveInsulinSensitivitySchedule(insulinSensitivitySchedule: insulinSensitivitySchedule)
            didSave?()
        }
    }
}
