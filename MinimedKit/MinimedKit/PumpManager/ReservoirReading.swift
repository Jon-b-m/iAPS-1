import Foundation
import LoopKit

public struct ReservoirReading: RawRepresentable, Equatable {
    public typealias RawValue = [String: Any]

    public let units: Double
    public let validAt: Date

    public init(units: Double, validAt: Date) {
        self.units = units
        self.validAt = validAt
    }

    public init?(rawValue: RawValue) {
        guard
            let units = rawValue["units"] as? Double,
            let validAt = rawValue["validAt"] as? Date
        else {
            return nil
        }

        self.units = units
        self.validAt = validAt
    }

    public var rawValue: RawValue {
        [
            "units": units,
            "validAt": validAt
        ]
    }
}

extension ReservoirReading: ReservoirValue {
    public var startDate: Date {
        validAt
    }

    public var unitVolume: Double {
        units
    }
}
