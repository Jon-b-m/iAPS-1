import Foundation

public struct TempBasalRecommendation: Equatable {
    public let unitsPerHour: Double
    public let duration: TimeInterval

    /// A special command which cancels any existing temp basals
    public static var cancel: TempBasalRecommendation {
        self.init(unitsPerHour: 0, duration: 0)
    }

    public init(unitsPerHour: Double, duration: TimeInterval) {
        self.unitsPerHour = unitsPerHour
        self.duration = duration
    }
}

extension TempBasalRecommendation: Codable {}
