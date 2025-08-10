import Foundation

struct TransmitterTimeRxMessage: TransmitterRxMessage {
    let status: UInt8
    let currentTime: UInt32
    let sessionStartTime: UInt32

    init?(data: Data) {
        guard data.count == 16, data.isCRCValid else {
            return nil
        }

        guard data.starts(with: .transmitterTimeRx) else {
            return nil
        }

        status = data[1]
        currentTime = data[2 ..< 6].toInt()
        sessionStartTime = data[6 ..< 10].toInt()
    }
}

extension TransmitterTimeRxMessage: Equatable {}

func == (lhs: TransmitterTimeRxMessage, rhs: TransmitterTimeRxMessage) -> Bool {
    lhs.currentTime == rhs.currentTime
}
