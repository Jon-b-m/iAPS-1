import Foundation

public struct PodInfoResponse: MessageBlock {
    public let blockType: MessageBlockType = .podInfoResponse
    public let podInfoResponseSubType: PodInfoResponseSubType
    public let podInfo: PodInfo
    public let data: Data

    public init(encodedData: Data) throws {
        guard let subType = PodInfoResponseSubType(rawValue: encodedData[2]) else {
            throw MessageError.unknownValue(value: encodedData[2], typeDescription: "PodInfoResponseSubType")
        }
        podInfoResponseSubType = subType
        let len = encodedData.count
        podInfo = try podInfoResponseSubType.podInfoType.init(encodedData: encodedData.subdata(in: 2 ..< len))
        data = encodedData
    }
}

extension PodInfoResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        "PodInfoResponse(\(blockType), \(podInfoResponseSubType), \(podInfo)"
    }
}
