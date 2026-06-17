import CoreData

/// 剪贴板记录 — Core Data 实体
@objc(ClipboardEntry)
public class ClipboardEntry: NSManagedObject {
    // Properties are defined in the xcdatamodeld
}

// MARK: - Core Data Properties

extension ClipboardEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardEntry> {
        return NSFetchRequest<ClipboardEntry>(entityName: "ClipboardEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var contentType: String?
    @NSManaged public var textContent: String?
    @NSManaged public var imageFileName: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var isPinned: Bool
}

// MARK: - Identifiable

extension ClipboardEntry: @unchecked Sendable {}
