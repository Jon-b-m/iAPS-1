import Foundation

struct SessionStartTxMessage: RespondableMessage {
    typealias Response = SessionStartRxMessage

    /// Time since activation in Dex seconds
    let startTime: UInt32

    /// Time in seconds since Unix Epoch
    let secondsSince1970: UInt32

    var data: Data {
        var data = Data(for: .sessionStartTx)
        data.append(startTime)
        data.append(secondsSince1970)
        return data.appendingCRC()
    }
}
