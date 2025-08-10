import Foundation

/// An event that contains an sgv
public protocol SensorValueGlucoseEvent: RelativeTimestampedGlucoseEvent {
    var sgv: Int {
        get
    }
}
