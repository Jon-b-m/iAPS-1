import Foundation

public struct PowerOnCarelinkMessageBody: MessageBody {
    public static var length: Int = 65

    public var txData: Data
    let duration: TimeInterval

    public init(duration: TimeInterval) {
        self.duration = duration
        let numArgs = 2
        let on = 1
        let durationMinutes = Int(ceil(duration / 60.0))
        txData = Data(hexadecimalString: String(format: "%02x%02x%02x", numArgs, on, durationMinutes))!
            .paddedTo(length: PowerOnCarelinkMessageBody.length)
    }

    public var description: String {
        "PowerOn(duration:\(duration))"
    }
}
