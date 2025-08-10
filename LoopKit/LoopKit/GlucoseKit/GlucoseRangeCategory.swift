import Foundation

public enum GlucoseRangeCategory: Int, CaseIterable {
    case belowRange
    case urgentLow
    case low
    case normal
    case high
    case aboveRange
}
