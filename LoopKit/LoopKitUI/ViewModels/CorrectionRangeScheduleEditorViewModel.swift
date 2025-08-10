import Foundation
import HealthKit
import LoopKit

struct CorrectionRangeScheduleEditorViewModel {
    let guardrail = Guardrail.correctionRange

    let glucoseTargetRangeSchedule: GlucoseRangeSchedule?

    let minValue: HKQuantity?

    var saveGlucoseTargetRangeSchedule: (_ glucoseTargetRangeSchedule: GlucoseRangeSchedule) -> Void

    init(
        mode: SettingsPresentationMode,
        therapySettingsViewModel: TherapySettingsViewModel,
        didSave: (() -> Void)? = nil
    ) {
        if mode == .acceptanceFlow {
            glucoseTargetRangeSchedule = therapySettingsViewModel.glucoseTargetRangeSchedule?
                .safeSchedule(with: therapySettingsViewModel.suspendThreshold?.quantity)
        } else {
            glucoseTargetRangeSchedule = therapySettingsViewModel.glucoseTargetRangeSchedule
        }
        minValue = Guardrail.minCorrectionRangeValue(suspendThreshold: therapySettingsViewModel.suspendThreshold)
        saveGlucoseTargetRangeSchedule = { [weak therapySettingsViewModel] glucoseTargetRangeSchedule in
            guard let therapySettingsViewModel = therapySettingsViewModel else {
                return
            }

            therapySettingsViewModel.saveCorrectionRange(range: glucoseTargetRangeSchedule)
            didSave?()
        }
    }
}
