import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 确保 App 完全初始化（MenuBarExtra 由 SwiftUI 自动管理）
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
