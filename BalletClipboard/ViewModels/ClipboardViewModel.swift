import AppKit
import Combine
import CoreData
import SwiftUI

/// 剪贴板历史 ViewModel
@MainActor
final class ClipboardViewModel: ObservableObject {
    @Published var items: [ClipboardEntry] = []
    @Published var searchText: String = ""
    @Published var retentionDays: Int = 3

    private let persistenceController: PersistenceController
    private let monitor: ClipboardMonitor
    private var cancellables = Set<AnyCancellable>()

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.monitor = ClipboardMonitor(persistenceController: persistenceController)
        loadRetentionPreference()
        fetchItems()
        startMonitoring()

        // 监听 Core Data 变化以自动刷新列表
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave,
            object: nil
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.fetchItems()
        }
        .store(in: &cancellables)
    }

    // MARK: - Computed

    var filteredItems: [ClipboardEntry] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { entry in
            entry.textContent?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    // MARK: - Data

    private func fetchItems() {
        let request: NSFetchRequest<ClipboardEntry> = ClipboardEntry.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]
        request.fetchLimit = 200 // 性能保护

        do {
            items = try persistenceController.container.viewContext.fetch(request)
            print("[ViewModel] 📋 刷新列表: \(items.count) 条记录")
        } catch {
            print("[ViewModel] ❌ 查询失败: \(error.localizedDescription)")
        }
    }

    private func startMonitoring() {
        monitor.start()
    }

    // MARK: - Actions

    func copyToClipboard(_ entry: ClipboardEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch entry.contentType {
        case "image":
            if let fileName = entry.imageFileName,
               let image = ImageStore.shared.load(fileName: fileName) {
                pasteboard.writeObjects([image])
                print("[ViewModel] 📋 图片已复制到剪贴板")
            }
        case "url", "text":
            if let text = entry.textContent {
                pasteboard.setString(text, forType: .string)
                print("[ViewModel] 📋 内容已复制到剪贴板")
            }
        default:
            break
        }

        // 刷新时间戳（提到最前）
        updateTimestamp(entry)
    }

    func togglePin(_ entry: ClipboardEntry) {
        let context = persistenceController.container.viewContext
        entry.isPinned.toggle()

        do {
            try context.save()
            fetchItems()
        } catch {
            print("[ViewModel] ❌ 置顶失败: \(error.localizedDescription)")
        }
    }

    func delete(_ entry: ClipboardEntry) {
        // 如果是图片，删除图片文件
        if entry.contentType == "image",
           let fileName = entry.imageFileName {
            ImageStore.shared.delete(fileName: fileName)
        }

        let context = persistenceController.container.viewContext
        context.delete(entry)

        do {
            try context.save()
            fetchItems()
            print("[ViewModel] 🗑 已删除一条记录")
        } catch {
            print("[ViewModel] ❌ 删除失败: \(error.localizedDescription)")
        }
    }

    private func updateTimestamp(_ entry: ClipboardEntry) {
        let context = persistenceController.container.viewContext
        entry.timestamp = Date()

        do {
            try context.save()
            fetchItems()
        } catch {
            print("[ViewModel] ⚠️ 更新时间戳失败: \(error.localizedDescription)")
        }
    }

    // MARK: - Settings

    func loadRetentionPreference() {
        let days = UserDefaults.standard.integer(forKey: "retentionDays")
        retentionDays = days > 0 ? days : 3
    }

    func saveRetentionPreference(_ days: Int) {
        retentionDays = days
        UserDefaults.standard.set(days, forKey: "retentionDays")
    }
}
