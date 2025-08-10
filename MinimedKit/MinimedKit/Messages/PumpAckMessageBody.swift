import Foundation

public class PumpAckMessageBody: DecodableMessageBody {
    public static let length = 1

    let rxData: Data

    public required init?(rxData: Data) {
        self.rxData = rxData
    }

    public var txData: Data {
        rxData
    }

    public var description: String {
        "PumpAck(\(rxData.hexadecimalString))"
    }
}
