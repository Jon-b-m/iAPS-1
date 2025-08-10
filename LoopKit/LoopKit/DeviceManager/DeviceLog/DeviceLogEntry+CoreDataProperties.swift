import CoreData
import Foundation

public extension DeviceLogEntry {
    @nonobjc class func fetchRequest() -> NSFetchRequest<DeviceLogEntry> {
        NSFetchRequest<DeviceLogEntry>(entityName: "Entry")
    }

    @NSManaged var primitiveType: String?
    @NSManaged var managerIdentifier: String?
    @NSManaged var deviceIdentifier: String?
    @NSManaged var message: String?
    @NSManaged var timestamp: Date?
    @NSManaged var modificationCounter: Int64
}

extension DeviceLogEntry: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type?.rawValue, forKey: .type)
        try container.encodeIfPresent(managerIdentifier, forKey: .managerIdentifier)
        try container.encodeIfPresent(deviceIdentifier, forKey: .deviceIdentifier)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encode(modificationCounter, forKey: .modificationCounter)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case managerIdentifier
        case deviceIdentifier
        case message
        case timestamp
        case modificationCounter
    }
}

extension DeviceLogEntry {
    func update(from entry: StoredDeviceLogEntry) {
        type = entry.type
        managerIdentifier = entry.managerIdentifier
        deviceIdentifier = entry.deviceIdentifier
        message = entry.message
        timestamp = entry.timestamp
    }
}
