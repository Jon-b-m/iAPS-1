import HealthKit

public protocol FavoriteFood {
    var name: String { get }
    var carbsQuantity: HKQuantity { get }
    var foodType: String { get }
    var absorptionTime: TimeInterval { get }
}

public extension FavoriteFood {
    var title: String {
        name + " " + foodType
    }

    func absorptionTimeString(formatter: DateComponentsFormatter) -> String {
        guard let string = formatter.string(from: absorptionTime) else {
            assertionFailure("Unable to format \(String(describing: absorptionTime))")
            return ""
        }
        return string
    }

    func carbsString(formatter: QuantityFormatter) -> String {
        guard let string = formatter.string(from: carbsQuantity) else {
            assertionFailure("Unable to format \(String(describing: carbsQuantity)) into gram format")
            return ""
        }
        return string
    }
}
