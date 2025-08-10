import Foundation

struct TransmitterVersionTxMessage {
    typealias Response = TransmitterVersionRxMessage

    let opcode: Opcode = .transmitterVersionTx
}
