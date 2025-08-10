import Foundation
import HealthKit
import LoopKit

struct SuspendThresholdEditorViewModel {
    let guardrail = Guardrail.suspendThreshold

    let suspendThreshold: HKQuantity?

    let suspendThresholdUnit: HKUnit

    let maxSuspendThresholdValue: HKQuantity

    var saveSuspendThreshold: (_ suspendThreshold: HKQuantity, _ displayGlucoseUnit: HKUnit) -> Void

    public init(
        therapySettingsViewModel: TherapySettingsViewModel,
        mode: SettingsPresentationMode,
        didSave: (() -> Void)? = nil
    )
    {
        suspendThreshold = therapySettingsViewModel.suspendThreshold?.quantity
        suspendThresholdUnit = therapySettingsViewModel.suspendThreshold?.unit ?? .milligramsPerDeciliter

        if mode == .acceptanceFlow {
            // During a review/acceptance flow, do not limit suspend threshold by other targets
            maxSuspendThresholdValue = Guardrail.suspendThreshold.absoluteBounds.upperBound
        } else {
            maxSuspendThresholdValue = Guardrail.maxSuspendThresholdValue(
                correctionRangeSchedule: therapySettingsViewModel.glucoseTargetRangeSchedule,
                preMealTargetRange: therapySettingsViewModel.correctionRangeOverrides.preMeal,
                workoutTargetRange: therapySettingsViewModel.correctionRangeOverrides.workout
            )
        }

        saveSuspendThreshold = { [weak therapySettingsViewModel] suspendThreshold, displayGlucoseUnit in
            guard let therapySettingsViewModel = therapySettingsViewModel else {
                return
            }
            therapySettingsViewModel.saveSuspendThreshold(quantity: suspendThreshold, withDisplayGlucoseUnit: displayGlucoseUnit)
            didSave?()
        }
    }
}
