import Foundation

public class ReadPumpStatusMessageBody: DecodableMessageBody {
    public static var length: Int = 65

    public var txData: Data

    public let bolusing: Bool
    public let suspended: Bool

    public required init?(rxData: Data) {
        guard rxData.count == type(of: self).length else {
            return nil
        }

        bolusing = rxData[2] > 0
        suspended = rxData[3] > 0
        txData = rxData
    }

    public init(bolusing: Bool, suspended: Bool) {
        self.bolusing = bolusing
        self.suspended = suspended
        txData = Data(hexadecimalString: "0303\(bolusing ? "01" : "00")\(suspended ? "01" : "00")")!.paddedTo(length: 65)
    }

    public var description: String {
        "ReadPumpStatus(bolusing:\(bolusing), suspended:\(suspended))"
    }
}
