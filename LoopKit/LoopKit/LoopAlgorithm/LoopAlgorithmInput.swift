import Foundation

public enum DoseRecommendationType: String {
    case manualBolus
    case automaticBolus
    case tempBasal
}

public struct LoopAlgorithmInput {
    public var predictionInput: LoopPredictionInput
    public var predictionDate: Date
    public var doseRecommendationType: DoseRecommendationType
}
