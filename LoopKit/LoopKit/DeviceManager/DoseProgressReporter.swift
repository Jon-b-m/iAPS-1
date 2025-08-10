import Foundation

public struct DoseProgress {
    public let deliveredUnits: Double
    public let percentComplete: Double

    public var isComplete: Bool {
        percentComplete >= 1.0 || fabs(percentComplete - 1.0) <= Double.ulpOfOne
    }

    public init(deliveredUnits: Double, percentComplete: Double) {
        self.deliveredUnits = deliveredUnits
        self.percentComplete = percentComplete
    }
}

public protocol DoseProgressObserver: AnyObject {
    func doseProgressReporterDidUpdate(_ doseProgressReporter: DoseProgressReporter)
}

public protocol DoseProgressReporter: AnyObject {
    var progress: DoseProgress { get }

    func addObserver(_ observer: DoseProgressObserver)

    func removeObserver(_ observer: DoseProgressObserver)
}
