import UIKit

/// A palette of colors for displaying charts
public struct ChartColorPalette {
    public let axisLine: UIColor
    public let axisLabel: UIColor
    public let grid: UIColor
    public let glucoseTint: UIColor
    public let insulinTint: UIColor
    public let carbTint: UIColor

    public init(
        axisLine: UIColor,
        axisLabel: UIColor,
        grid: UIColor,
        glucoseTint: UIColor,
        insulinTint: UIColor,
        carbTint: UIColor
    ) {
        self.axisLine = axisLine
        self.axisLabel = axisLabel
        self.grid = grid
        self.glucoseTint = glucoseTint
        self.insulinTint = insulinTint
        self.carbTint = carbTint
    }
}
