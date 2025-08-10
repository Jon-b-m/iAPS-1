import CoreData
import Foundation

public extension SettingsObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SettingsObject> {
        NSFetchRequest<SettingsObject>(entityName: "SettingsObject")
    }

    @NSManaged var data: Data
    @NSManaged var date: Date
    @NSManaged var modificationCounter: Int64
}

extension SettingsObject: Encodable {
    func encode(to encoder: Encoder) throws {
        try EncodableSettingsObject(self).encode(to: encoder)
    }
}

private struct EncodableSettingsObject: Encodable {
    var data: StoredSettings
    var date: Date
    var modificationCounter: Int64

    init(_ object: SettingsObject) throws {
        data = try PropertyListDecoder().decode(StoredSettings.self, from: object.data)
        date = object.date
        modificationCounter = object.modificationCounter
    }
}
