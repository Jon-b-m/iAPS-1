import CoreData

class DosingDecisionObject: NSManagedObject {
    var hasUpdatedModificationCounter: Bool { changedValues().keys.contains("modificationCounter") }

    func updateModificationCounter() {
        setPrimitiveValue(managedObjectContext!.modificationCounter!, forKey: "modificationCounter") }

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        updateModificationCounter()
    }

    override public func willSave() {
        if isUpdated, !hasUpdatedModificationCounter {
            updateModificationCounter()
        }
        super.willSave()
    }
}
