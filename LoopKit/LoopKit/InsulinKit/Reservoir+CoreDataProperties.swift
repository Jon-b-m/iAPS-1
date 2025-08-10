import CoreData
import Foundation

extension Reservoir {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Reservoir> {
        NSFetchRequest<Reservoir>(entityName: "Reservoir")
    }

    @NSManaged var createdAt: Date!
    @NSManaged var date: Date!
    @NSManaged var primitiveVolume: NSNumber?
    @NSManaged var raw: Data?
}
