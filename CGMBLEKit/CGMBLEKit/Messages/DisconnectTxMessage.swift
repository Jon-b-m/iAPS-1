import Foundation

struct DisconnectTxMessage: TransmitterTxMessage {
    var data: Data {
        Data(for: .disconnectTx)
    }
}
