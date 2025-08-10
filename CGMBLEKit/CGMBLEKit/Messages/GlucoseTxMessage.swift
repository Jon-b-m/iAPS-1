import Foundation

struct GlucoseTxMessage: RespondableMessage {
    typealias Response = GlucoseRxMessage

    var data: Data {
        Data(for: .glucoseTx).appendingCRC()
    }
}
