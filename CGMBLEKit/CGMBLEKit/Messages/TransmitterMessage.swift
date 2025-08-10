import Foundation

/// A data sequence written to the transmitter
protocol TransmitterTxMessage {
    /// The data to write
    var data: Data { get }
}

protocol RespondableMessage: TransmitterTxMessage {
    associatedtype Response: TransmitterRxMessage
}

/// A data sequence received by the transmitter
protocol TransmitterRxMessage {
    init?(data: Data)
}
