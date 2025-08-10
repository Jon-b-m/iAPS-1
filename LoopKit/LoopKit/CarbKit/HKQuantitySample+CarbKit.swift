import HealthKit

let LegacyMetadataKeyAbsorptionTime = "com.loudnate.CarbKit.HKMetadataKey.AbsorptionTimeMinutes"
let MetadataKeyAbsorptionTime = "com.loopkit.AbsorptionTime"
let MetadataKeyUserCreatedDate = "com.loopkit.CarbKit.HKMetadataKey.UserCreatedDate"
let MetadataKeyUserUpdatedDate = "com.loopkit.CarbKit.HKMetadataKey.UserUpdatedDate"

public extension HKQuantitySample {
    var foodType: String? {
        metadata?[HKMetadataKeyFoodType] as? String
    }

    var absorptionTime: TimeInterval? {
        metadata?[MetadataKeyAbsorptionTime] as? TimeInterval
            ?? metadata?[LegacyMetadataKeyAbsorptionTime] as? TimeInterval
    }

    var createdByCurrentApp: Bool {
        sourceRevision.source == HKSource.default()
    }

    var userCreatedDate: Date? {
        metadata?[MetadataKeyUserCreatedDate] as? Date
    }

    var userUpdatedDate: Date? {
        metadata?[MetadataKeyUserUpdatedDate] as? Date
    }
}
