import HealthKit
import LoopKit
import SwiftUI

struct InsulinModelChartView: UIViewRepresentable {
    let chartManager: ChartsManager
    var glucoseUnit: HKUnit
    var selectedInsulinModelValues: [GlucoseValue]
    var unselectedInsulinModelValues: [[GlucoseValue]]
    var glucoseDisplayRange: ClosedRange<HKQuantity>

    func makeUIView(context _: Context) -> ChartContainerView {
        let view = ChartContainerView()
        view.chartGenerator = { [chartManager] frame in
            chartManager.chart(atIndex: 0, frame: frame)?.view
        }
        return view
    }

    func updateUIView(_ chartContainerView: ChartContainerView, context _: Context) {
        chartManager.invalidateChart(atIndex: 0)
        insulinModelChart.glucoseUnit = glucoseUnit
        insulinModelChart.setSelectedInsulinModelValues(selectedInsulinModelValues)
        insulinModelChart.setUnselectedInsulinModelValues(unselectedInsulinModelValues)
        insulinModelChart.glucoseDisplayRange = glucoseDisplayRange
        chartManager.prerender()
        chartContainerView.reloadChart()
    }

    private var insulinModelChart: InsulinModelChart {
        guard chartManager.charts.count == 1, let insulinModelChart = chartManager.charts.first as? InsulinModelChart else {
            fatalError("Expected exactly one insulin model chart in ChartsManager")
        }

        return insulinModelChart
    }
}
