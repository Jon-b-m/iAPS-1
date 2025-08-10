import Foundation
import HealthKit

public struct DailyQuantitySchedule<T: RawRepresentable>: DailySchedule {
    public typealias RawValue = [String: Any]
    public let unit: HKUnit
    var valueSchedule: DailyValueSchedule<T>

    public init?(unit: HKUnit, dailyItems: [RepeatingScheduleValue<T>], timeZone: TimeZone? = nil) {
        guard let valueSchedule = DailyValueSchedule<T>(dailyItems: dailyItems, timeZone: timeZone) else {
            return nil
        }

        self.unit = unit
        self.valueSchedule = valueSchedule
    }

    init(unit: HKUnit, valueSchedule: DailyValueSchedule<T>) {
        self.unit = unit
        self.valueSchedule = valueSchedule
    }

    public init?(rawValue: RawValue) {
        guard let rawUnit = rawValue["unit"] as? String,
              let valueSchedule = DailyValueSchedule<T>(rawValue: rawValue)
        else {
            return nil
        }

        unit = HKUnit(from: rawUnit)
        self.valueSchedule = valueSchedule
    }

    public var items: [RepeatingScheduleValue<T>] {
        valueSchedule.items
    }

    public var timeZone: TimeZone {
        get {
            valueSchedule.timeZone
        }
        set {
            valueSchedule.timeZone = newValue
        }
    }

    public var rawValue: RawValue {
        var rawValue = valueSchedule.rawValue

        rawValue["unit"] = unit.unitString

        return rawValue
    }

    public func between(start startDate: Date, end endDate: Date) -> [AbsoluteScheduleValue<T>] {
        valueSchedule.between(start: startDate, end: endDate)
    }

    public func value(at time: Date) -> T {
        valueSchedule.value(at: time)
    }
}

extension DailyQuantitySchedule: Codable where T: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unit = HKUnit(from: try container.decode(String.self, forKey: .unit))
        valueSchedule = try container.decode(DailyValueSchedule<T>.self, forKey: .valueSchedule)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unit.unitString, forKey: .unit)
        try container.encode(valueSchedule, forKey: .valueSchedule)
    }

    private enum CodingKeys: String, CodingKey {
        case unit
        case valueSchedule
    }
}

extension DailyQuantitySchedule: CustomDebugStringConvertible {
    public var debugDescription: String {
        String(reflecting: rawValue)
    }
}

public typealias SingleQuantitySchedule = DailyQuantitySchedule<Double>

public extension DailyQuantitySchedule where T == Double {
    func quantity(at time: Date) -> HKQuantity {
        HKQuantity(unit: unit, doubleValue: valueSchedule.value(at: time))
    }

    func averageValue() -> Double {
        var total: Double = 0

        for (index, item) in valueSchedule.items.enumerated() {
            var endTime = valueSchedule.maxTimeInterval

            if index < valueSchedule.items.endIndex - 1 {
                endTime = valueSchedule.items[index + 1].startTime
            }

            total += (endTime - item.startTime) * item.value
        }

        return total / valueSchedule.repeatInterval
    }

    func averageQuantity() -> HKQuantity {
        HKQuantity(unit: unit, doubleValue: averageValue())
    }

    func lowestValue() -> Double? {
        valueSchedule.items.min(by: { $0.value < $1.value })?.value
    }

    var quantities: [RepeatingScheduleValue<HKQuantity>] {
        items.map {
            RepeatingScheduleValue<HKQuantity>(
                startTime: $0.startTime,
                value: HKQuantity(unit: unit, doubleValue: $0.value)
            )
        }
    }

    func quantities(using unit: HKUnit) -> [RepeatingScheduleValue<HKQuantity>] {
        items.map {
            RepeatingScheduleValue<HKQuantity>(
                startTime: $0.startTime,
                value: HKQuantity(unit: unit, doubleValue: $0.value)
            )
        }
    }

    func truncatingBetween(start startDate: Date, end endDate: Date) -> [AbsoluteScheduleValue<T>] {
        let values = between(start: startDate, end: endDate)
        return values.map { item in
            let start = max(item.startDate, startDate)
            let end = min(item.endDate, endDate)
            return AbsoluteScheduleValue<T>(startDate: start, endDate: end, value: item.value)
        }
    }

    init?(
        unit: HKUnit,
        dailyQuantities: [RepeatingScheduleValue<HKQuantity>],
        timeZone: TimeZone? = nil
    )
    {
        guard let valueSchedule = DailyValueSchedule(
            dailyItems: dailyQuantities.map {
                RepeatingScheduleValue(startTime: $0.startTime, value: $0.value.doubleValue(for: unit))
            },
            timeZone: timeZone
        )
        else {
            return nil
        }

        self.unit = unit
        self.valueSchedule = valueSchedule
    }
}

public extension DailyQuantitySchedule where T == DoubleRange {
    init?(
        unit: HKUnit,
        dailyQuantities: [RepeatingScheduleValue<ClosedRange<HKQuantity>>],
        timeZone: TimeZone? = nil
    )
    {
        guard let valueSchedule = DailyValueSchedule(
            dailyItems: dailyQuantities.map {
                RepeatingScheduleValue(startTime: $0.startTime, value: $0.value.doubleRange(for: unit))
            },
            timeZone: timeZone
        )
        else {
            return nil
        }

        self.unit = unit
        self.valueSchedule = valueSchedule
    }
}

extension DailyQuantitySchedule: Equatable where T: Equatable {
    public static func == (lhs: DailyQuantitySchedule<T>, rhs: DailyQuantitySchedule<T>) -> Bool {
        lhs.valueSchedule == rhs.valueSchedule && lhs.unit.unitString == rhs.unit.unitString
    }
}

public extension DailyQuantitySchedule where T: Numeric {
    static func * (lhs: DailyQuantitySchedule, rhs: DailyQuantitySchedule) -> DailyQuantitySchedule {
        let unit = lhs.unit.unitMultiplied(by: rhs.unit)
        let schedule = DailyValueSchedule.zip(lhs.valueSchedule, rhs.valueSchedule).map(*)
        return DailyQuantitySchedule(unit: unit, valueSchedule: schedule)
    }
}

public extension DailyQuantitySchedule where T: FloatingPoint {
    static func / (lhs: DailyQuantitySchedule, rhs: DailyQuantitySchedule) -> DailyQuantitySchedule {
        let unit = lhs.unit.unitDivided(by: rhs.unit)
        let schedule = DailyValueSchedule.zip(lhs.valueSchedule, rhs.valueSchedule).map(/)
        return DailyQuantitySchedule(unit: unit, valueSchedule: schedule)
    }
}

public extension DailyQuantitySchedule where T == Double {
    func quantitiesBetween(start: Date, end: Date) -> [AbsoluteScheduleValue<HKQuantity>] {
        between(start: start, end: end).map {
            AbsoluteScheduleValue(
                startDate: $0.startDate,
                endDate: $0.endDate,
                value: HKQuantity(unit: unit, doubleValue: $0.value)
            )
        }
    }
}
