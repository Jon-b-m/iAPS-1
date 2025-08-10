import Foundation

public struct UnknownMessageBody: DecodableMessageBody, DictionaryRepresentable {
    public static var length = 0

    let rxData: Data

    public init?(rxData: Data) {
        self.rxData = rxData
    }

    public var txData: Data {
        rxData
    }

    public var dictionaryRepresentation: [String: Any] {
        ["rawData": rxData]
    }

    public var description: String {
        "UnknownMessage(\(rxData.hexadecimalString))"
    }
}
