import Foundation

struct SessionStopTxMessage: RespondableMessage {
    typealias Response = SessionStopRxMessage

    let stopTime: UInt32

    var data: Data {
        var data = Data(for: .sessionStopTx)
        data.append(stopTime)
        return data.appendingCRC()
    }
}
