import CoreData

class SettingsObject: NSManagedObject {
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
