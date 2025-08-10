import HealthKit

public extension HKObject {
    var syncIdentifier: String? { metadata?[HKMetadataKeySyncIdentifier] as? String }
    var syncVersion: Int? { metadata?[HKMetadataKeySyncVersion] as? Int }
}
