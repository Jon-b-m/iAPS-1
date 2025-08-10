import Foundation

public enum BatteryChemistryType: Int, CustomStringConvertible, Identifiable, CaseIterable {
    public var id: Int {
        rawValue
    }

    case alkaline = 0
    case lithium

    public var description: String {
        switch self {
        case .alkaline:
            return LocalizedString("Alkaline", comment: "Describing the battery chemistry as Alkaline")
        case .lithium:
            return LocalizedString("Lithium", comment: "Describing the battery chemistry as Lithium")
        }
    }

    public var maxVoltage: Double {
        switch self {
        case .alkaline:
            return 1.47
        case .lithium:
            return 1.58
        }
    }

    public var minVoltage: Double {
        switch self {
        case .alkaline:
            return 1.18
        case .lithium:
            return 1.32
        }
    }

    public func chargeRemaining(at voltage: Measurement<UnitElectricPotentialDifference>) -> Double {
        let computed = (voltage.converted(to: .volts).value - minVoltage) / (maxVoltage - minVoltage)
        return max(min(computed, 1), 0)
    }
}
