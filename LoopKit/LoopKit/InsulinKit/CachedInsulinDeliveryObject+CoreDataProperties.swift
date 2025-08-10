import CoreData
import Foundation

public extension CachedInsulinDeliveryObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CachedInsulinDeliveryObject> {
        NSFetchRequest<CachedInsulinDeliveryObject>(entityName: "CachedInsulinDeliveryObject")
    }

    @NSManaged var uuid: UUID?
    @NSManaged var provenanceIdentifier: String
    @NSManaged var hasLoopKitOrigin: Bool
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date
    @NSManaged var syncIdentifier: String?
    @NSManaged var value: Double
    @NSManaged var primitiveScheduledBasalRate: NSNumber?
    @NSManaged var primitiveProgrammedTempBasalRate: NSNumber?
    @NSManaged var primitiveReason: NSNumber?
    @NSManaged var createdAt: Date
    @NSManaged var deletedAt: Date?
    @NSManaged var primitiveInsulinType: NSNumber?
    @NSManaged var primitiveAutomaticallyIssued: NSNumber?
    @NSManaged var manuallyEntered: Bool
    @NSManaged var isSuspend: Bool
    @NSManaged var isMutable: Bool
    @NSManaged var modificationCounter: Int64
    @NSManaged var wasProgrammedByPumpUI: Bool
}
