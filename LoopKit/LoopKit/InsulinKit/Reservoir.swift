import CoreData
import Foundation

class Reservoir: NSManagedObject {
    var volume: Double! {
        get {
            willAccessValue(forKey: "volume")
            defer { didAccessValue(forKey: "volume") }
            return primitiveVolume?.doubleValue
        }
        set {
            willChangeValue(forKey: "volume")
            defer { didChangeValue(forKey: "volume") }
            primitiveVolume = newValue != nil ? NSNumber(value: newValue) : nil
        }
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()

        createdAt = Date()
    }
}
