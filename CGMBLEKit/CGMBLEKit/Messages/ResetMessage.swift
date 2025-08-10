import Foundation

struct ResetTxMessage: RespondableMessage {
    typealias Response = ResetRxMessage

    var data: Data {
        Data(for: .resetTx).appendingCRC()
    }
}

struct ResetRxMessage: TransmitterRxMessage {
    let status: UInt8

    init?(data: Data) {
        guard data.count >= 2, data.starts(with: .resetRx) else {
            return nil
        }

        status = data[1]
    }
}
