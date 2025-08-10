import Foundation

public class ChangeTempBasalCarelinkMessageBody: MessageBody {
    public static var length: Int = 65

    public var txData: Data

    let unitsPerHour: Double
    let duration: TimeInterval

    public init(unitsPerHour: Double, duration: TimeInterval) {
        self.unitsPerHour = unitsPerHour
        self.duration = duration

        let length = 3
        let strokesPerUnit: Double = 40
        let strokes = Int(unitsPerHour * strokesPerUnit)
        let timeSegments = Int(duration / TimeInterval(30 * 60))

        let data = Data(hexadecimalString: String(format: "%02x%04x%02x", length, strokes, timeSegments))!

        txData = data.paddedTo(length: type(of: self).length)
    }

    public var description: String {
        "ChangeTempBasal(rate:\(unitsPerHour) U/hr duration:\(duration)"
    }
}
