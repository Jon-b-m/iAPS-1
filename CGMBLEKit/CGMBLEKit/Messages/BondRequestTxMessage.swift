import Foundation

/// Initiates a bond with the central
struct BondRequestTxMessage: TransmitterTxMessage {
    var data: Data {
        Data(for: .bondRequest)
    }
}
