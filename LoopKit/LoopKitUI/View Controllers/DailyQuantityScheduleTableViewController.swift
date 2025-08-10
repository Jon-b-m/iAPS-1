import HealthKit
import UIKit

public class DailyQuantityScheduleTableViewController: SingleValueScheduleTableViewController {
    public var unit = HKUnit.gram() {
        didSet {
            unitDisplayString = unit.unitDivided(by: .internationalUnit()).shortLocalizedUnitString()
        }
    }

    override var preferredValueFractionDigits: Int {
        unit.preferredFractionDigits
    }
}
