import Combine
import HealthKit
import LoopKit
import SwiftUI

public protocol TherapySettingsViewModelDelegate: AnyObject {
    func syncBasalRateSchedule(
        items: [RepeatingScheduleValue<Double>],
        completion: @escaping (Result<BasalRateSchedule, Error>) -> Void
    )
    func syncDeliveryLimits(deliveryLimits: DeliveryLimits, completion: @escaping (Result<DeliveryLimits, Error>) -> Void)
    func saveCompletion(therapySettings: TherapySettings)
    func pumpSupportedIncrements() -> PumpSupportedIncrements?
}

public class TherapySettingsViewModel: ObservableObject {
    @Published public var therapySettings: TherapySettings
    private let initialTherapySettings: TherapySettings
    let sensitivityOverridesEnabled: Bool
    let adultChildInsulinModelSelectionEnabled: Bool
    public var prescription: Prescription?

    private weak var delegate: TherapySettingsViewModelDelegate?

    public init(
        therapySettings: TherapySettings,
        pumpSupportedIncrements _: (() -> PumpSupportedIncrements?)? = nil,
        sensitivityOverridesEnabled: Bool = false,
        adultChildInsulinModelSelectionEnabled: Bool = false,
        prescription: Prescription? = nil,
        delegate: TherapySettingsViewModelDelegate? = nil
    ) {
        self.therapySettings = therapySettings
        initialTherapySettings = therapySettings
        self.sensitivityOverridesEnabled = sensitivityOverridesEnabled
        self.adultChildInsulinModelSelectionEnabled = adultChildInsulinModelSelectionEnabled
        self.prescription = prescription
        self.delegate = delegate
    }

    var deliveryLimits: DeliveryLimits {
        DeliveryLimits(
            maximumBasalRate: therapySettings.maximumBasalRatePerHour
                .map { HKQuantity(unit: .internationalUnitsPerHour, doubleValue: $0) },
            maximumBolus: therapySettings.maximumBolus.map { HKQuantity(unit: .internationalUnit(), doubleValue: $0) }
        )
    }

    var suspendThreshold: GlucoseThreshold? {
        therapySettings.suspendThreshold
    }

    var glucoseTargetRangeSchedule: GlucoseRangeSchedule? {
        therapySettings.glucoseTargetRangeSchedule
    }

    func glucoseTargetRangeSchedule(for glucoseUnit: HKUnit) -> GlucoseRangeSchedule? {
        glucoseTargetRangeSchedule?.schedule(for: glucoseUnit)
    }

    var correctionRangeOverrides: CorrectionRangeOverrides {
        CorrectionRangeOverrides(
            preMeal: therapySettings.correctionRangeOverrides?.preMeal,
            workout: therapySettings.correctionRangeOverrides?.workout
        )
    }

    var correctionRangeScheduleRange: ClosedRange<HKQuantity> {
        precondition(therapySettings.glucoseTargetRangeSchedule != nil)
        return therapySettings.glucoseTargetRangeSchedule!.scheduleRange()
    }

    var insulinSensitivitySchedule: InsulinSensitivitySchedule? {
        therapySettings.insulinSensitivitySchedule
    }

    func insulinSensitivitySchedule(for glucoseUnit: HKUnit) -> InsulinSensitivitySchedule? {
        insulinSensitivitySchedule?.schedule(for: glucoseUnit)
    }

    /// Reset to initial
    public func reset() {
        therapySettings = initialTherapySettings
    }
}

// MARK: Passing along to the delegate

public extension TherapySettingsViewModel {
    var maximumBasalScheduleEntryCount: Int? {
        pumpSupportedIncrements()?.maximumBasalScheduleEntryCount
    }

    func pumpSupportedIncrements() -> PumpSupportedIncrements? {
        delegate?.pumpSupportedIncrements()
    }

    func syncBasalRateSchedule(
        items: [RepeatingScheduleValue<Double>],
        completion: @escaping (Result<BasalRateSchedule, Error>) -> Void
    ) {
        delegate?.syncBasalRateSchedule(items: items, completion: completion)
    }

    func syncDeliveryLimits(deliveryLimits: DeliveryLimits, completion: @escaping (Result<DeliveryLimits, Error>) -> Void) {
        delegate?.syncDeliveryLimits(deliveryLimits: deliveryLimits, completion: completion)
    }
}

// MARK: Saving

public extension TherapySettingsViewModel {
    func saveCorrectionRange(range: GlucoseRangeSchedule) {
        therapySettings.glucoseTargetRangeSchedule = range
        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveCorrectionRangeOverride(
        preset _: CorrectionRangeOverrides.Preset,
        correctionRangeOverrides: CorrectionRangeOverrides
    ) {
        therapySettings.correctionRangeOverrides = correctionRangeOverrides
        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveSuspendThreshold(quantity: HKQuantity, withDisplayGlucoseUnit displayGlucoseUnit: HKUnit) {
        therapySettings.suspendThreshold = GlucoseThreshold(
            unit: displayGlucoseUnit,
            value: quantity.doubleValue(for: displayGlucoseUnit)
        )

        // TODO: Eventually target editors should support conflicting initial values
        // But for now, ensure target ranges do not conflict with suspend threshold.
        if let targetSchedule = therapySettings.glucoseTargetRangeSchedule {
            let threshold = quantity.doubleValue(for: targetSchedule.unit)
            let newItems = targetSchedule.items.map { item in
                RepeatingScheduleValue<DoubleRange>.init(
                    startTime: item.startTime,
                    value: DoubleRange(
                        minValue: max(threshold, item.value.minValue),
                        maxValue: max(threshold, item.value.maxValue)
                    )
                )
            }
            therapySettings.glucoseTargetRangeSchedule = GlucoseRangeSchedule(unit: targetSchedule.unit, dailyItems: newItems)
        }

        if let overrides = therapySettings.correctionRangeOverrides {
            let adjusted = [overrides.preMeal, overrides.workout].map { item -> ClosedRange<HKQuantity>? in
                guard let item = item else {
                    return nil
                }
                return ClosedRange<HKQuantity>.init(
                    uncheckedBounds: (
                        lower: max(quantity, item.lowerBound),
                        upper: max(quantity, item.upperBound)
                    )
                )
            }
            therapySettings.correctionRangeOverrides = CorrectionRangeOverrides(
                preMeal: adjusted[0],
                workout: adjusted[1]
            )
        }

        if let presets = therapySettings.overridePresets {
            therapySettings.overridePresets = presets.map { preset in
                if let targetRange = preset.settings.targetRange {
                    var newPreset = preset
                    newPreset.settings = TemporaryScheduleOverrideSettings(
                        targetRange: ClosedRange<HKQuantity>.init(
                            uncheckedBounds: (
                                lower: max(quantity, targetRange.lowerBound),
                                upper: max(quantity, targetRange.upperBound)
                            )
                        ),
                        insulinNeedsScaleFactor: preset.settings.insulinNeedsScaleFactor
                    )
                    return newPreset
                } else {
                    return preset
                }
            }
        }

        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveBasalRates(basalRates: BasalRateSchedule) {
        therapySettings.basalRateSchedule = basalRates
        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveDeliveryLimits(limits: DeliveryLimits) {
        therapySettings.maximumBasalRatePerHour = limits.maximumBasalRate?.doubleValue(for: .internationalUnitsPerHour)
        therapySettings.maximumBolus = limits.maximumBolus?.doubleValue(for: .internationalUnit())
        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveInsulinModel(insulinModelPreset: ExponentialInsulinModelPreset) {
        therapySettings.defaultRapidActingModel = insulinModelPreset
        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveCarbRatioSchedule(carbRatioSchedule: CarbRatioSchedule) {
        therapySettings.carbRatioSchedule = carbRatioSchedule
        delegate?.saveCompletion(therapySettings: therapySettings)
    }

    func saveInsulinSensitivitySchedule(insulinSensitivitySchedule: InsulinSensitivitySchedule) {
        therapySettings.insulinSensitivitySchedule = insulinSensitivitySchedule
        delegate?.saveCompletion(therapySettings: therapySettings)
    }
}
