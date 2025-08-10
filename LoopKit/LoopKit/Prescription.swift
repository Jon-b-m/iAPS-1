import Foundation

public protocol Prescription {
    /// Date prescription was prescribed
    var datePrescribed: Date { get }
    /// Name of clinician prescribing
    var providerName: String { get }
}
