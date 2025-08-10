import Foundation

struct KeepAliveTxMessage: TransmitterTxMessage {
    let time: UInt8

    var data: Data {
        var data = Data(for: .keepAlive)
        data.append(time)
        return data
    }
}
