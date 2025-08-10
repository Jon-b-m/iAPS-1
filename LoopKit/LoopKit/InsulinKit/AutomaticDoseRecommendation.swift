import Foundation

public struct AutomaticDoseRecommendation: Equatable {
    public let basalAdjustment: TempBasalRecommendation?
    public let bolusUnits: Double?

    public init(basalAdjustment: TempBasalRecommendation?, bolusUnits: Double? = nil) {
        self.basalAdjustment = basalAdjustment
        self.bolusUnits = bolusUnits
    }
}

extension AutomaticDoseRecommendation: Codable {}
