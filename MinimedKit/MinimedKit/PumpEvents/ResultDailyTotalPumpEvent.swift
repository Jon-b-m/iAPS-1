import Foundation

public struct ResultDailyTotalPumpEvent: PumpEvent {
    public let length: Int
    public let rawData: Data
    public let timestamp: DateComponents
    public let totalUnits: Double

    public init?(availableData: Data, pumpModel: PumpModel) {
        if pumpModel.larger {
            length = 10
        } else {
            length = 7
        }

        guard length <= availableData.count else {
            return nil
        }

        rawData = availableData.subdata(in: 0 ..< length)

        let strokes = Int(bigEndianBytes: availableData.subdata(in: 3 ..< 5))
        totalUnits = Double(strokes) / 40

        timestamp = DateComponents(pumpEventBytes: availableData.subdata(in: 5 ..< 7))
    }

    public var dictionaryRepresentation: [String: Any] {
        [
            "_type": "ResultDailyTotal",
            "totalUnits": totalUnits,
            "validDate": String(format: "%04d-%02d-%02d", timestamp.year!, timestamp.month!, timestamp.day!)
        ]
    }
}
