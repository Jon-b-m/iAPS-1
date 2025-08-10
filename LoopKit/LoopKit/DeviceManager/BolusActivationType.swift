public enum BolusActivationType: String, Codable {
    case automatic
    case manualNoRecommendation
    case manualRecommendationAccepted
    case manualRecommendationChanged
    case none

    public var isAutomatic: Bool {
        self == .automatic
    }

    public static func activationTypeFor(recommendedAmount: Double?, bolusAmount: Double?) -> BolusActivationType {
        guard let bolusAmount = bolusAmount else { return recommendedAmount != nil ? .automatic : .none }
        guard let recommendedAmount = recommendedAmount else { return .manualNoRecommendation }
        return recommendedAmount =~ bolusAmount ? .manualRecommendationAccepted : .manualRecommendationChanged
    }
}
