import CoreData
import Foundation

public extension DosingDecisionObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<DosingDecisionObject> {
        NSFetchRequest<DosingDecisionObject>(entityName: "DosingDecisionObject")
    }

    @NSManaged var data: Data
    @NSManaged var date: Date
    @NSManaged var modificationCounter: Int64
}

extension DosingDecisionObject: Encodable {
    func encode(to encoder: Encoder) throws {
        try EncodableDosingDecisionObject(self).encode(to: encoder)
    }
}

private struct EncodableDosingDecisionObject: Encodable {
    var data: StoredDosingDecision
    var date: Date
    var modificationCounter: Int64

    init(_ object: DosingDecisionObject) throws {
        data = try PropertyListDecoder().decode(StoredDosingDecision.self, from: object.data)
        date = object.date
        modificationCounter = object.modificationCounter
    }
}
