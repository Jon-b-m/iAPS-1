import CoreData
import Foundation
import HealthKit

public extension CachedGlucoseObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CachedGlucoseObject> {
        NSFetchRequest<CachedGlucoseObject>(entityName: "CachedGlucoseObject")
    }

    /// This is the UUID provided from HealthKit.  Nil if not (yet) stored in HealthKit.  Note: it is _not_ a unique identifier for this object.
    @NSManaged var uuid: UUID?
    @NSManaged var provenanceIdentifier: String
    @NSManaged var syncIdentifier: String?
    @NSManaged var primitiveSyncVersion: NSNumber?
    @NSManaged var value: Double
    @NSManaged var unitString: String
    @NSManaged var startDate: Date
    @NSManaged var isDisplayOnly: Bool
    @NSManaged var wasUserEntered: Bool
    @NSManaged var modificationCounter: Int64
    @NSManaged var primitiveDevice: Data?
    @NSManaged var primitiveCondition: String?
    @NSManaged var primitiveTrend: NSNumber?
    @NSManaged var trendRateValue: NSNumber?
    /// This is the date when this object is eligible for writing to HealthKit.  For example, if it is required to delay writing
    /// data to HealthKit, this date will be in the future.  If the date is in the past, then it is written to HealthKit as soon as possible,
    /// and this value is set to `nil`.  A `nil` value either means that this object has already been written to HealthKit, or it is
    /// not eligible for HealthKit in the first place (for example, if a user has denied permissions at the time the sample was taken).
    @NSManaged var healthKitEligibleDate: Date?
}

extension CachedGlucoseObject: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(uuid, forKey: .uuid)
        try container.encode(provenanceIdentifier, forKey: .provenanceIdentifier)
        try container.encodeIfPresent(syncIdentifier, forKey: .syncIdentifier)
        try container.encodeIfPresent(syncVersion, forKey: .syncVersion)
        try container.encode(value, forKey: .value)
        try container.encode(unitString, forKey: .unitString)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(isDisplayOnly, forKey: .isDisplayOnly)
        try container.encode(wasUserEntered, forKey: .wasUserEntered)
        try container.encode(modificationCounter, forKey: .modificationCounter)
        try container.encodeIfPresent(device, forKey: .device)
        try container.encodeIfPresent(condition, forKey: .condition)
        try container.encodeIfPresent(trend, forKey: .trend)
        try container.encodeIfPresent(trendRateValue?.doubleValue, forKey: .trendRateValue)
        try container.encodeIfPresent(healthKitEligibleDate, forKey: .healthKitEligibleDate)
    }

    private enum CodingKeys: String, CodingKey {
        case uuid
        case provenanceIdentifier
        case syncIdentifier
        case syncVersion
        case value
        case unitString
        case startDate
        case isDisplayOnly
        case wasUserEntered
        case modificationCounter
        case device
        case condition
        case trend
        case trendRateValue
        case healthKitEligibleDate
    }
}

extension GlucoseTrend: Codable {}
