import CoreData
import Foundation

public extension CachedCarbObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CachedCarbObject> {
        NSFetchRequest<CachedCarbObject>(entityName: "CachedCarbObject")
    }

    @NSManaged var primitiveAbsorptionTime: NSNumber?
    @NSManaged var createdByCurrentApp: Bool
    @NSManaged var foodType: String?
    @NSManaged var grams: Double
    @NSManaged var startDate: Date
    @NSManaged var uuid: UUID?
    @NSManaged var provenanceIdentifier: String
    @NSManaged var syncIdentifier: String?
    @NSManaged var primitiveSyncVersion: NSNumber?
    @NSManaged var userCreatedDate: Date?
    @NSManaged var userUpdatedDate: Date?
    @NSManaged var userDeletedDate: Date?
    @NSManaged var primitiveOperation: NSNumber
    @NSManaged var addedDate: Date?
    @NSManaged var supercededDate: Date?
    @NSManaged var anchorKey: Int64
}

extension CachedCarbObject: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(absorptionTime, forKey: .absorptionTime)
        try container.encode(createdByCurrentApp, forKey: .createdByCurrentApp)
        try container.encodeIfPresent(foodType, forKey: .foodType)
        try container.encode(grams, forKey: .grams)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(uuid, forKey: .uuid)
        try container.encode(provenanceIdentifier, forKey: .provenanceIdentifier)
        try container.encodeIfPresent(syncIdentifier, forKey: .syncIdentifier)
        try container.encodeIfPresent(syncVersion, forKey: .syncVersion)
        try container.encodeIfPresent(userCreatedDate, forKey: .userCreatedDate)
        try container.encodeIfPresent(userUpdatedDate, forKey: .userUpdatedDate)
        try container.encodeIfPresent(userDeletedDate, forKey: .userDeletedDate)
        try container.encodeIfPresent(operation, forKey: .operation)
        try container.encodeIfPresent(addedDate, forKey: .addedDate)
        try container.encodeIfPresent(supercededDate, forKey: .supercededDate)
        try container.encode(anchorKey, forKey: .anchorKey)
    }

    private enum CodingKeys: String, CodingKey {
        case absorptionTime
        case createdByCurrentApp
        case foodType
        case grams
        case startDate
        case uuid
        case provenanceIdentifier
        case syncIdentifier
        case syncVersion
        case userCreatedDate
        case userUpdatedDate
        case userDeletedDate
        case operation
        case addedDate
        case supercededDate
        case anchorKey
    }
}
