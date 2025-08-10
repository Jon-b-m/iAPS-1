import Foundation

public protocol GlucosePredictionInput {
    var glucoseHistory: [StoredGlucoseSample] { get }
    var doses: [DoseEntry] { get }
    var carbEntries: [StoredCarbEntry] { get }
}

public protocol GlucosePrediction {
    var glucose: [PredictedGlucoseValue] { get }
}

public protocol GlucosePredictionAlgorithm {
    associatedtype InputType: GlucosePredictionInput
    associatedtype OutputType: GlucosePrediction

    static func generatePrediction(input: InputType, startDate: Date?) throws -> OutputType
}

extension LoopAlgorithm: GlucosePredictionAlgorithm {}
