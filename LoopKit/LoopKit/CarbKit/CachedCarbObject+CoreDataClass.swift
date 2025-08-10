import CoreData
import Foundation
import HealthKit

class CachedCarbObject: NSManagedObject {
    var absorptionTime: TimeInterval? {
        get {
            willAccessValue(forKey: "absorptionTime")
            defer { didAccessValue(forKey: "absorptionTime") }
            return primitiveAbsorptionTime?.doubleValue
        }
        set {
            willChangeValue(forKey: "absorptionTime")
            defer { didChangeValue(forKey: "absorptionTime") }
            primitiveAbsorptionTime = newValue != nil ? NSNumber(value: newValue!) : nil
        }
    }

    var syncVersion: Int? {
        get {
            willAccessValue(forKey: "syncVersion")
            defer { didAccessValue(forKey: "syncVersion") }
            return primitiveSyncVersion?.intValue
        }
        set {
            willChangeValue(forKey: "syncVersion")
            defer { didChangeValue(forKey: "syncVersion") }
            primitiveSyncVersion = newValue != nil ? NSNumber(value: newValue!) : nil
        }
    }

    var operation: Operation {
        get {
            willAccessValue(forKey: "operation")
            defer { didAccessValue(forKey: "operation") }
            return Operation(rawValue: primitiveOperation.intValue)!
        }
        set {
            willChangeValue(forKey: "operation")
            defer { didChangeValue(forKey: "operation") }
            primitiveOperation = NSNumber(value: newValue.rawValue)
        }
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(managedObjectContext!.anchorKey!, forKey: "anchorKey")
    }
}

// MARK: - Helpers

extension CachedCarbObject {
    var quantity: HKQuantity { HKQuantity(unit: .gram(), doubleValue: grams) }
}

// MARK: - Operations

extension CachedCarbObject {
    // Loop
    func create(
        from entry: NewCarbEntry,
        provenanceIdentifier: String,
        syncIdentifier: String,
        syncVersion: Int = 1,
        on date: Date = Date()
    ) {
        absorptionTime = entry.absorptionTime
        createdByCurrentApp = true
        foodType = entry.foodType
        grams = entry.quantity.doubleValue(for: .gram())
        startDate = entry.startDate
        uuid = nil

        self.provenanceIdentifier = provenanceIdentifier
        self.syncIdentifier = syncIdentifier
        self.syncVersion = syncVersion

        userCreatedDate = entry.date
        userUpdatedDate = nil
        userDeletedDate = nil

        operation = .create
        addedDate = date
        supercededDate = nil
    }

    // HealthKit
    func create(from sample: HKQuantitySample, on date: Date = Date()) {
        absorptionTime = sample.absorptionTime
        createdByCurrentApp = sample.createdByCurrentApp
        foodType = sample.foodType
        grams = sample.quantity.doubleValue(for: .gram())
        startDate = sample.startDate
        uuid = sample.uuid

        provenanceIdentifier = sample.provenanceIdentifier
        syncIdentifier = sample.syncIdentifier
        syncVersion = sample.syncVersion

        userCreatedDate = sample.userCreatedDate
        userUpdatedDate = nil
        userDeletedDate = nil

        operation = .create
        addedDate = date
        supercededDate = nil
    }

    // Loop
    func update(from entry: NewCarbEntry, replacing object: CachedCarbObject, on date: Date = Date()) {
        precondition(object.createdByCurrentApp)
        precondition(object.syncIdentifier != nil)
        precondition(object.syncVersion != nil)

        absorptionTime = entry.absorptionTime
        createdByCurrentApp = object.createdByCurrentApp
        foodType = entry.foodType
        grams = entry.quantity.doubleValue(for: .gram())
        startDate = entry.startDate
        uuid = nil

        provenanceIdentifier = object.provenanceIdentifier
        syncIdentifier = object.syncIdentifier
        syncVersion = object.syncVersion.map { $0 + 1 }

        userCreatedDate = object.userCreatedDate
        userUpdatedDate = entry.date
        userDeletedDate = nil

        operation = .update
        addedDate = date
        supercededDate = nil
    }

    // HealthKit
    func update(from sample: HKQuantitySample, replacing object: CachedCarbObject, on date: Date = Date()) {
        absorptionTime = sample.absorptionTime
        createdByCurrentApp = sample.createdByCurrentApp
        foodType = sample.foodType
        grams = sample.quantity.doubleValue(for: .gram())
        startDate = sample.startDate
        uuid = sample.uuid

        provenanceIdentifier = sample.provenanceIdentifier
        syncIdentifier = sample.syncIdentifier
        syncVersion = sample.syncVersion

        userCreatedDate = object.userCreatedDate
        userUpdatedDate = sample.userUpdatedDate
        userDeletedDate = nil

        operation = .update
        addedDate = date
        supercededDate = nil
    }

    // Either
    func delete(from object: CachedCarbObject, on date: Date = Date()) {
        absorptionTime = object.absorptionTime
        createdByCurrentApp = object.createdByCurrentApp
        foodType = object.foodType
        grams = object.grams
        startDate = object.startDate
        uuid = object.uuid

        provenanceIdentifier = object.provenanceIdentifier
        syncIdentifier = object.syncIdentifier
        syncVersion = object.syncVersion

        userCreatedDate = object.userCreatedDate
        userUpdatedDate = object.userUpdatedDate
        userDeletedDate = object.createdByCurrentApp ? date : nil // Cannot know actual user deleted data from other app

        operation = .delete
        addedDate = date
        supercededDate = nil
    }
}

// MARK: - Watch Synchronization

extension CachedCarbObject {
    func update(from object: SyncCarbObject) {
        absorptionTime = object.absorptionTime
        createdByCurrentApp = object.createdByCurrentApp
        foodType = object.foodType
        grams = object.grams
        startDate = object.startDate
        uuid = object.uuid

        provenanceIdentifier = object.provenanceIdentifier
        syncIdentifier = object.syncIdentifier
        syncVersion = object.syncVersion

        userCreatedDate = object.userCreatedDate
        userUpdatedDate = object.userUpdatedDate
        userDeletedDate = object.userDeletedDate

        operation = object.operation
        addedDate = object.addedDate
        supercededDate = object.supercededDate
    }
}

// MARK: - HealthKit Synchronization

extension CachedCarbObject {
    var quantitySample: HKQuantitySample {
        var metadata = [String: Any]()

        metadata[HKMetadataKeyFoodType] = foodType
        metadata[MetadataKeyAbsorptionTime] = absorptionTime

        metadata[HKMetadataKeySyncIdentifier] = syncIdentifier
        metadata[HKMetadataKeySyncVersion] = syncVersion

        metadata[MetadataKeyUserCreatedDate] = userCreatedDate
        metadata[MetadataKeyUserUpdatedDate] = userUpdatedDate

        return HKQuantitySample(
            type: HealthKitSampleStore.carbType,
            quantity: quantity,
            start: startDate,
            end: startDate,
            metadata: metadata
        )
    }
}

// MARK: - DEPRECATED - Used only for migration

extension CachedCarbObject {
    func create(from entry: StoredCarbEntry) {
        absorptionTime = entry.absorptionTime
        createdByCurrentApp = entry.createdByCurrentApp
        foodType = entry.foodType
        grams = entry.quantity.doubleValue(for: .gram())
        startDate = entry.startDate
        uuid = entry.uuid

        provenanceIdentifier = entry.provenanceIdentifier
        syncIdentifier = entry.syncIdentifier
        syncVersion = entry.syncVersion

        operation = .create
        addedDate = nil
        supercededDate = nil
    }
}
