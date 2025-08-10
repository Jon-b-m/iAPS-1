import Foundation

struct SessionKeys {
    var ck: Data
    var nonce: Nonce
    var msgSequenceNumber: Int
}

struct SessionNegotiationResynchronization {
    let synchronizedEapSqn: EapSqn
    let msgSequenceNumber: UInt8
}
