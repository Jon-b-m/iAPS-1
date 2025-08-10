import Foundation

extension Data {
    func paddedTo(length: Int) -> Data {
        var data = self
        data.append(contentsOf: [UInt8](repeating: 0, count: length - data.count))
        return data
    }
}

public class CarelinkLongMessageBody: DecodableMessageBody {
    public static var length: Int = 65

    let rxData: Data

    public required init?(rxData: Data) {
        self.rxData = rxData.paddedTo(length: type(of: self).length)
    }

    public var txData: Data {
        rxData
    }

    public var description: String {
        "CarelinkLongMessage(\(rxData.hexadecimalString))"
    }
}

public class CarelinkShortMessageBody: MessageBody {
    public static var length: Int = 1

    let data: Data

    public convenience init() {
        self.init(rxData: Data(repeating: 0, count: 1))!
    }

    public required init?(rxData: Data) {
        data = rxData

        if rxData.count != type(of: self).length {
            return nil
        }
    }

    public var txData: Data {
        data
    }

    public var description: String {
        "CarelinkShortMessage(\(data.hexadecimalString))"
    }
}
