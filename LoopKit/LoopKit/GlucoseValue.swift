import HealthKit

public protocol GlucoseValue: SampleValue {}

public struct SimpleGlucoseValue: Equatable, GlucoseValue {
    public let startDate: Date
    public let endDate: Date
    public let quantity: HKQuantity

    public init(startDate: Date, endDate: Date? = nil, quantity: HKQuantity) {
        self.startDate = startDate
        self.endDate = endDate ?? startDate
        self.quantity = quantity
    }

    public init(_ glucoseValue: GlucoseValue) {
        startDate = glucoseValue.startDate
        endDate = glucoseValue.endDate
        quantity = glucoseValue.quantity
    }
}

extension SimpleGlucoseValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        quantity = HKQuantity(
            unit: HKUnit(from: try container.decode(String.self, forKey: .quantityUnit)),
            doubleValue: try container.decode(Double.self, forKey: .quantity)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(quantity.doubleValue(for: .milligramsPerDeciliter), forKey: .quantity)
        try container.encode(HKUnit.milligramsPerDeciliter.unitString, forKey: .quantityUnit)
    }

    private enum CodingKeys: String, CodingKey {
        case startDate
        case endDate
        case quantity
        case quantityUnit
    }
}

public struct PredictedGlucoseValue: Equatable, GlucoseValue {
    public let startDate: Date
    public let quantity: HKQuantity

    public init(startDate: Date, quantity: HKQuantity) {
        self.startDate = startDate
        self.quantity = quantity
    }
}

extension PredictedGlucoseValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startDate = try container.decode(Date.self, forKey: .startDate)
        quantity = HKQuantity(
            unit: HKUnit(from: try container.decode(String.self, forKey: .quantityUnit)),
            doubleValue: try container.decode(Double.self, forKey: .quantity)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(quantity.doubleValue(for: .milligramsPerDeciliter), forKey: .quantity)
        try container.encode(HKUnit.milligramsPerDeciliter.unitString, forKey: .quantityUnit)
    }

    private enum CodingKeys: String, CodingKey {
        case startDate
        case quantity
        case quantityUnit
    }
}

extension HKQuantitySample: GlucoseValue {}
