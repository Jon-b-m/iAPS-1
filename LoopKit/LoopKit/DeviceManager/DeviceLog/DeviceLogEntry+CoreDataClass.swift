import CoreData
import Foundation

class DeviceLogEntry: NSManagedObject {
    var type: DeviceLogEntryType? {
        get {
            willAccessValue(forKey: "type")
            defer { didAccessValue(forKey: "type") }
            guard let primitiveType = primitiveType else {
                return nil
            }
            return DeviceLogEntryType(rawValue: primitiveType)
        }
        set {
            willChangeValue(forKey: "type")
            defer { didChangeValue(forKey: "type") }
            primitiveType = newValue?.rawValue
        }
    }

    var hasUpdatedModificationCounter: Bool { changedValues().keys.contains("modificationCounter") }

    func updateModificationCounter() {
        setPrimitiveValue(managedObjectContext!.modificationCounter!, forKey: "modificationCounter") }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        updateModificationCounter()
    }

    override func willSave() {
        if isUpdated, !hasUpdatedModificationCounter {
            updateModificationCounter()
        }
        super.willSave()
    }
}
