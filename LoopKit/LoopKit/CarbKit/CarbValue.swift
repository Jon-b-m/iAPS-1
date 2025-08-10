import Foundation
import HealthKit

public struct CarbValue: SampleValue {
    public let startDate: Date
    public let endDate: Date
    public var value: Double

    public var quantity: HKQuantity {
        HKQuantity(unit: .gram(), doubleValue: value)
    }

    public init(startDate: Date, endDate: Date? = nil, value: Double) {
        self.startDate = startDate
        self.endDate = endDate ?? startDate
        self.value = value
    }
}

extension CarbValue: Equatable {}

extension CarbValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        value = try container.decode(Double.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(value, forKey: .value)
    }

    private enum CodingKeys: String, CodingKey {
        case startDate
        case endDate
        case value
    }
}
