import SwiftUI

public struct LoopUIColorPalette {
    public let guidanceColors: GuidanceColors
    public let carbTintColor: Color
    public let glucoseTintColor: Color
    public let insulinTintColor: Color
    public let loopStatusColorPalette: StateColorPalette
    public let chartColorPalette: ChartColorPalette

    public init(
        guidanceColors: GuidanceColors,
        carbTintColor: Color,
        glucoseTintColor: Color,
        insulinTintColor: Color,
        loopStatusColorPalette: StateColorPalette,
        chartColorPalette: ChartColorPalette
    ) {
        self.guidanceColors = guidanceColors
        self.carbTintColor = carbTintColor
        self.glucoseTintColor = glucoseTintColor
        self.insulinTintColor = insulinTintColor
        self.loopStatusColorPalette = loopStatusColorPalette
        self.chartColorPalette = chartColorPalette
    }
}
