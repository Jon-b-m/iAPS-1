import Foundation

struct AuthRequestRxMessage: TransmitterRxMessage {
    let tokenHash: Data
    let challenge: Data

    init?(data: Data) {
        guard data.count >= 17 else {
            return nil
        }

        guard data.starts(with: .authRequestRx) else {
            return nil
        }

        tokenHash = data.subdata(in: 1 ..< 9)
        challenge = data.subdata(in: 9 ..< 17)
    }
}
