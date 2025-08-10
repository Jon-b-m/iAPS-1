import SwiftCharts
import UIKit

public final class ChartAxisValueDoubleLog: ChartAxisValueDoubleScreenLoc {
    let unitString: String?

    public init(
        actualDouble: Double,
        unitString: String? = nil,
        formatter: NumberFormatter,
        labelSettings: ChartLabelSettings = ChartLabelSettings()
    ) {
        let screenLocDouble: Double

        switch actualDouble {
        case let x where x < 0:
            screenLocDouble = -log(-x + 1)
        case let x where x > 0:
            screenLocDouble = log(x + 1)
        default: // 0
            screenLocDouble = 0
        }

        self.unitString = unitString

        super.init(
            screenLocDouble: screenLocDouble,
            actualDouble: actualDouble,
            formatter: formatter,
            labelSettings: labelSettings
        )
    }

    public init(screenLocDouble: Double, formatter: NumberFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        let actualDouble: Double

        switch screenLocDouble {
        case let x where x < 0:
            actualDouble = -pow(M_E, -x) + 1
        case let x where x > 0:
            actualDouble = pow(M_E, x) - 1
        default: // 0
            actualDouble = 0
        }

        unitString = nil

        super.init(
            screenLocDouble: screenLocDouble,
            actualDouble: actualDouble,
            formatter: formatter,
            labelSettings: labelSettings
        )
    }

    override public var description: String {
        let suffix = unitString != nil ? " \(unitString!)" : ""

        return super.description + suffix
    }
}
