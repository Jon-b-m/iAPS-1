import Foundation
import LoopKit
import SwiftCharts
import UIKit

public class InsulinModelChart: GlucoseChart, ChartProviding {
    /// The chart points for the selected model
    public private(set) var selectedInsulinModelChartPoints: [ChartPoint] = [] {
        didSet {
            if let lastDate = selectedInsulinModelChartPoints.last?.x as? ChartAxisValueDate {
                updateEndDate(lastDate.date)
            }
        }
    }

    public private(set) var unselectedInsulinModelChartPoints: [[ChartPoint]] = [] {
        didSet {
            for points in unselectedInsulinModelChartPoints {
                if let lastDate = points.last?.x as? ChartAxisValueDate {
                    updateEndDate(lastDate.date)
                }
            }
        }
    }

    public private(set) var endDate: Date?

    private func updateEndDate(_ date: Date) {
        if endDate == nil || date > endDate! {
            endDate = date
        }
    }
}

public extension InsulinModelChart {
    func didReceiveMemoryWarning() {}

    func generate(
        withFrame frame: CGRect,
        xAxisModel: ChartAxisModel,
        xAxisValues: [ChartAxisValue],
        axisLabelSettings: ChartLabelSettings,
        guideLinesLayerSettings: ChartGuideLinesLayerSettings,
        colors: ChartColorPalette,
        chartSettings: ChartSettings,
        labelsWidthY: CGFloat,
        gestureRecognizer _: UIGestureRecognizer?,
        traitCollection _: UITraitCollection
    ) -> Chart
    {
        let yAxisValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(
            glucoseDisplayRangePoints,
            minSegmentCount: 2,
            maxSegmentCount: 5,
            multiple: glucoseUnit.chartableIncrement / 2,
            axisValueGenerator: {
                ChartAxisValueDouble(round($0), labelSettings: axisLabelSettings)
            },
            addPaddingSegmentIfEdge: false
        )

        let yAxisModel = ChartAxisModel(
            axisValues: yAxisValues,
            lineColor: colors.axisLine,
            labelSpaceReservationMode: .fixed(labelsWidthY)
        )

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(
            chartSettings: chartSettings,
            chartFrame: frame,
            xModel: xAxisModel,
            yModel: yAxisModel
        )

        // Grid lines
        let gridLayer = ChartGuideLinesForValuesLayer(
            xAxis: coordsSpace.xAxisLayer.axis,
            yAxis: coordsSpace.yAxisLayer.axis,
            settings: guideLinesLayerSettings,
            axisValuesX: Array(xAxisValues.dropFirst().dropLast()),
            axisValuesY: yAxisValues
        )

        // Selected line
        var selectedLayer: ChartLayer?

        if selectedInsulinModelChartPoints.count > 1 {
            let lineModel = ChartLineModel.predictionLine(
                points: selectedInsulinModelChartPoints,
                color: colors.glucoseTint,
                width: 2
            )

            selectedLayer = ChartPointsLineLayer(
                xAxis: coordsSpace.xAxisLayer.axis,
                yAxis: coordsSpace.yAxisLayer.axis,
                lineModels: [lineModel]
            )
        }

        var unselectedLineModels = [ChartLineModel]()

        for points in unselectedInsulinModelChartPoints where points.count > 1 {
            unselectedLineModels.append(ChartLineModel.predictionLine(
                points: points,
                color: UIColor.secondaryLabel,
                width: 1
            ))
        }

        // Unselected lines
        var unselectedLayer: ChartLayer?

        if !unselectedLineModels.isEmpty {
            unselectedLayer = ChartPointsLineLayer(
                xAxis: coordsSpace.xAxisLayer.axis,
                yAxis: coordsSpace.yAxisLayer.axis,
                lineModels: unselectedLineModels
            )
        }

        let layers: [ChartLayer?] = [
            gridLayer,
            coordsSpace.xAxisLayer,
            coordsSpace.yAxisLayer,
            unselectedLayer,
            selectedLayer
        ]

        return Chart(
            frame: frame,
            innerFrame: coordsSpace.chartInnerFrame,
            settings: chartSettings,
            layers: layers.compactMap { $0 }
        )
    }
}

public extension InsulinModelChart {
    func setSelectedInsulinModelValues(_ values: [GlucoseValue]) {
        selectedInsulinModelChartPoints = glucosePointsFromValues(values)
    }

    func setUnselectedInsulinModelValues(_ values: [[GlucoseValue]]) {
        unselectedInsulinModelChartPoints = values.map(glucosePointsFromValues)
    }
}
