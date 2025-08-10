import Foundation

struct CalibrationDataTxMessage: RespondableMessage {
    typealias Response = CalibrationDataRxMessage

    var data: Data {
        Data(for: .calibrationDataTx).appendingCRC()
    }
}
