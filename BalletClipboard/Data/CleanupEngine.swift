import CoreData
import Foundation

/// 自动清理引擎 — 定期删除过期记录
final class CleanupEngine: @unchecked Sendable {
    private var timer: Timer?
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.performCleanup()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func performCleanup() {
        // TODO: Phase 2 实现
        print("[CleanupEngine] 清理检查...")
    }
}
