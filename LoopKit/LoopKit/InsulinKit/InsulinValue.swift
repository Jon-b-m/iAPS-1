import Foundation

public struct InsulinValue: TimelineValue, Equatable {
    public let startDate: Date
    public let value: Double

    public init(startDate: Date, value: Double) {
        self.startDate = startDate
        self.value = value
    }
}

extension InsulinValue: Codable {}
