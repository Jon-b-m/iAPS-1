import Foundation
import HealthKit

public struct LoopPredictionInput: GlucosePredictionInput {
    // Algorithm input time range: t-10h to t
    public var glucoseHistory: [StoredGlucoseSample]

    // Algorithm input time range: t-16h to t
    public var doses: [DoseEntry]

    // Algorithm input time range: t-10h to t
    public var carbEntries: [StoredCarbEntry]

    public var settings: LoopAlgorithmSettings

    public init(
        glucoseHistory: [StoredGlucoseSample],
        doses: [DoseEntry],
        carbEntries: [StoredCarbEntry],
        settings: LoopAlgorithmSettings
    )
    {
        self.glucoseHistory = glucoseHistory
        self.doses = doses
        self.carbEntries = carbEntries
        self.settings = settings
    }
}

extension LoopPredictionInput: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        glucoseHistory = try container.decode([StoredGlucoseSample].self, forKey: .glucoseHistory)
        doses = try container.decode([DoseEntry].self, forKey: .doses)
        carbEntries = try container.decode([StoredCarbEntry].self, forKey: .carbEntries)
        settings = try container.decode(LoopAlgorithmSettings.self, forKey: .settings)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(glucoseHistory, forKey: .glucoseHistory)
        try container.encode(doses, forKey: .doses)
        try container.encode(carbEntries, forKey: .carbEntries)
        try container.encode(settings, forKey: .settings)
    }

    private enum CodingKeys: String, CodingKey {
        case glucoseHistory
        case doses
        case carbEntries
        case settings
    }
}

extension LoopPredictionInput {
    var simplifiedForFixture: LoopPredictionInput {
        LoopPredictionInput(
            glucoseHistory: glucoseHistory.map {
                StoredGlucoseSample(
                    startDate: $0.startDate,
                    quantity: $0.quantity,
                    isDisplayOnly: $0.isDisplayOnly
                )
            },
            doses: doses.map {
                DoseEntry(type: $0.type, startDate: $0.startDate, endDate: $0.endDate, value: $0.value, unit: $0.unit)
            },
            carbEntries: carbEntries.map {
                StoredCarbEntry(startDate: $0.startDate, quantity: $0.quantity, absorptionTime: $0.absorptionTime)
            },
            settings: settings.simplifiedForFixture
        )
    }

    public func printFixture() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(simplifiedForFixture),
           let json = String(data: data, encoding: .utf8)
        {
            print(json)
        }
    }
}
