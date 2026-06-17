@preconcurrency import CoreData

/// Core Data 持久化控制器
final class PersistenceController: @unchecked Sendable {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BalletClipboard")

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        // 合并策略：新数据覆盖旧数据
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data 加载失败: \(error.localizedDescription)")
            }
        }
    }

    /// 创建后台上下文用于写入
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
