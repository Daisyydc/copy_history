import AppKit
@preconcurrency import CoreData

/// 剪贴板监听器 — 轮询 NSPasteboard 变化
final class ClipboardMonitor: @unchecked Sendable {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    /// 开始监听 (0.5s 轮询)
    func start() {
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            self?.checkPasteboard()
        }
        timer?.tolerance = 0.1
        print("[ClipboardMonitor] ✅ 监听已启动 (changeCount: \(lastChangeCount))")
    }

    /// 停止监听
    func stop() {
        timer?.invalidate()
        timer = nil
        print("[ClipboardMonitor] ⏹ 监听已停止")
    }

    // MARK: - Private

    private func checkPasteboard() {
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // 读取剪贴板内容
        let types = pasteboard.types ?? []
        print("[ClipboardMonitor] 📋 检测到剪贴板变化, types: \(types.map { $0.rawValue })")

        // 1. 检查图片
        if types.contains(.tiff) || types.contains(.png) {
            if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
                handleImage(image)
                return
            }
        }

        // 2. 检查文字
        if let text = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            handleText(text)
            return
        }
    }

    private func handleText(_ text: String) {
        // 去重：与最近一条文字记录比对
        if isDuplicate(text: text) {
            print("[ClipboardMonitor] ⏭ 跳过重复文字")
            return
        }

        // 判断是否是 URL
        let isURL = URLChecker.isURL(text)
        let contentType = isURL ? "url" : "text"
        print("[ClipboardMonitor] 💾 保存\(contentType): \(text.prefix(50))...")

        persistenceController.container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            let entry = ClipboardEntry(context: context)
            entry.id = UUID()
            entry.contentType = contentType
            entry.textContent = text
            entry.timestamp = Date()
            entry.isPinned = false

            do {
                try context.save()
                print("[ClipboardMonitor] ✅ 已保存到数据库")
            } catch {
                print("[ClipboardMonitor] ❌ 保存失败: \(error.localizedDescription)")
            }
        }
    }

    private func handleImage(_ image: NSImage) {
        // 保存图片到文件
        guard let fileName = ImageStore.shared.save(image) else {
            print("[ClipboardMonitor] ❌ 图片保存失败")
            return
        }
        print("[ClipboardMonitor] 💾 保存图片: \(fileName)")

        persistenceController.container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            let entry = ClipboardEntry(context: context)
            entry.id = UUID()
            entry.contentType = "image"
            entry.imageFileName = fileName
            entry.textContent = "[图片]"
            entry.timestamp = Date()
            entry.isPinned = false

            do {
                try context.save()
                print("[ClipboardMonitor] ✅ 图片已保存到数据库")
            } catch {
                print("[ClipboardMonitor] ❌ 图片保存失败: \(error.localizedDescription)")
                // 回滚：删除已保存的图片文件
                ImageStore.shared.delete(fileName: fileName)
            }
        }
    }

    // MARK: - Deduplication

    private func isDuplicate(text: String) -> Bool {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<ClipboardEntry> = ClipboardEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "contentType != %@", "image")

        do {
            let results = try context.fetch(request)
            if let last = results.first, last.textContent == text {
                return true
            }
        } catch {
            print("[ClipboardMonitor] ⚠️ 去重查询失败: \(error)")
        }
        return false
    }
}
