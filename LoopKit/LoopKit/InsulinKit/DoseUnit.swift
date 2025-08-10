import Foundation

public enum DoseUnit: String {
    case unitsPerHour = "U/hour"
    case units = "U"
}

extension DoseUnit: Codable {}
