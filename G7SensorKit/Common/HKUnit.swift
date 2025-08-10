import HealthKit

extension HKUnit {
    static let milligramsPerDeciliter: HKUnit = {
        HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
    }()

    static let milligramsPerDeciliterPerMinute: HKUnit = {
        HKUnit.milligramsPerDeciliter.unitDivided(by: .minute())
    }()
}
