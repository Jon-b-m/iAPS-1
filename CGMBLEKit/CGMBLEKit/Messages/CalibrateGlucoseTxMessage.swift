import Foundation

struct CalibrateGlucoseTxMessage: RespondableMessage {
    typealias Response = CalibrateGlucoseRxMessage

    let time: UInt32
    let glucose: UInt16

    var data: Data {
        var data = Data(for: .calibrateGlucoseTx)
        data.append(glucose)
        data.append(time)
        return data.appendingCRC()
    }
}
