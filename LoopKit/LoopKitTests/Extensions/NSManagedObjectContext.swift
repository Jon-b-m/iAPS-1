import CoreData
import Foundation

extension NSManagedObjectContext {
    func all<T: NSManagedObject>() -> [T] {
        let request = NSFetchRequest<T>(entityName: T.entity().name!)
        return (try? fetch(request)) ?? []
    }
}
