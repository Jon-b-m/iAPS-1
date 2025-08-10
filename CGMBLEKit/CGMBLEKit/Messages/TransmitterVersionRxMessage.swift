import Foundation

struct TransmitterVersionRxMessage: TransmitterRxMessage {
    let status: UInt8
    let firmwareVersion: [UInt8]

    init?(data: Data) {
        guard data.count == 19, data.isCRCValid else {
            return nil
        }

        guard data.starts(with: .transmitterVersionRx) else {
            return nil
        }

        status = data[1]
        firmwareVersion = data[2 ..< 6].map { $0 }
    }
}
