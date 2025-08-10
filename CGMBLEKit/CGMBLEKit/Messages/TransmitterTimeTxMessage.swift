import Foundation

struct TransmitterTimeTxMessage: RespondableMessage {
    typealias Response = TransmitterTimeRxMessage

    var data: Data {
        Data(for: .transmitterTimeTx).appendingCRC()
    }
}
