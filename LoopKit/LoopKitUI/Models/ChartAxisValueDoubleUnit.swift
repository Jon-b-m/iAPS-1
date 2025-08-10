import SwiftCharts
import UIKit

public final class ChartAxisValueDoubleUnit: ChartAxisValueDouble {
    let unitString: String

    public init(_ double: Double, unitString: String, formatter: NumberFormatter) {
        self.unitString = unitString

        super.init(double, formatter: formatter)
    }

    init(_ double: Double, unitString: String) {
        self.unitString = unitString

        super.init(double)
    }

    override public var description: String {
        formatter.string(from: scalar, unit: unitString) ?? ""
    }
}
