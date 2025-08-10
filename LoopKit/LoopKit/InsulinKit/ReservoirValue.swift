import CoreData
import Foundation

public protocol ReservoirValue: TimelineValue {
    var startDate: Date { get }
    var unitVolume: Double { get }
}

struct StoredReservoirValue: ReservoirValue {
    let startDate: Date
    let unitVolume: Double
    let objectIDURL: URL
}

extension Reservoir: ReservoirValue {
    var startDate: Date {
        date
    }

    var unitVolume: Double {
        volume
    }

    var storedReservoirValue: StoredReservoirValue {
        StoredReservoirValue(startDate: startDate, unitVolume: unitVolume, objectIDURL: objectID.uriRepresentation())
    }
}
