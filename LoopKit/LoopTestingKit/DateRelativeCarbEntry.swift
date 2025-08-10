import HealthKit
import LoopKit

struct DateRelativeCarbEntry: DateRelativeQuantity, Codable {
    var gramValue: Double
    var dateOffset: TimeInterval
    var enteredAtOffset: TimeInterval?
    var absorptionTime: TimeInterval

    var quantity: HKQuantity {
        HKQuantity(unit: .gram(), doubleValue: gramValue)
    }

    func newCarbEntry(relativeTo referenceDate: Date) -> NewCarbEntry {
        let startDate = referenceDate.addingTimeInterval(dateOffset)
        return NewCarbEntry(quantity: quantity, startDate: startDate, foodType: nil, absorptionTime: absorptionTime)
    }

    func enteredAt(relativeTo referenceDate: Date) -> Date {
        referenceDate.addingTimeInterval(enteredAtOffset ?? dateOffset)
    }
}
