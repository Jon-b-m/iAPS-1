import Foundation
import HealthKit
import LoopKit

struct CorrectionRangeOverridesEditorViewModel {
    let correctionRangeOverrides: CorrectionRangeOverrides

    let suspendThreshold: GlucoseThreshold?

    let correctionRangeScheduleRange: ClosedRange<HKQuantity>

    let preset: CorrectionRangeOverrides.Preset

    let guardrail: Guardrail<HKQuantity>

    var saveCorrectionRangeOverride: (_ correctionRangeOverrides: CorrectionRangeOverrides) -> Void

    public init(
        therapySettingsViewModel: TherapySettingsViewModel,
        preset: CorrectionRangeOverrides.Preset,
        didSave: (() -> Void)? = nil
    )
    {
        correctionRangeOverrides = therapySettingsViewModel.correctionRangeOverrides
        suspendThreshold = therapySettingsViewModel.suspendThreshold
        correctionRangeScheduleRange = therapySettingsViewModel.correctionRangeScheduleRange
        guardrail = Guardrail.correctionRangeOverride(
            for: preset,
            correctionRangeScheduleRange: therapySettingsViewModel.correctionRangeScheduleRange,
            suspendThreshold: therapySettingsViewModel.suspendThreshold
        )
        self.preset = preset

        saveCorrectionRangeOverride = { [weak therapySettingsViewModel] correctionRangeOverrides in
            guard let therapySettingsViewModel = therapySettingsViewModel else {
                return
            }
            therapySettingsViewModel.saveCorrectionRangeOverride(
                preset: preset,
                correctionRangeOverrides: correctionRangeOverrides
            )
            didSave?()
        }
    }
}
