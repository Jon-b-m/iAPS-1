import HealthKit

public extension HKUnit {
    static let milligramsPerDeciliter: HKUnit = {
        HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
    }()

    static let millimolesPerLiter: HKUnit = {
        HKUnit.moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose).unitDivided(by: .liter())
    }()

    static let milligramsPerDeciliterPerMinute: HKUnit = {
        HKUnit.milligramsPerDeciliter.unitDivided(by: .minute())
    }()

    static let millimolesPerLiterPerMinute: HKUnit = {
        HKUnit.millimolesPerLiter.unitDivided(by: .minute())
    }()

    static let internationalUnitsPerHour: HKUnit = {
        HKUnit.internationalUnit().unitDivided(by: .hour())
    }()
}
