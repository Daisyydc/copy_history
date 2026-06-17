import AppKit
import Foundation

/// 图片文件管理器 — 存储/读取/删除剪贴板图片
final class ImageStore: @unchecked Sendable {
    static let shared = ImageStore()

    private let imagesDirectory: URL

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        imagesDirectory = appSupport
            .appendingPathComponent("BalletClipboard")
            .appendingPathComponent("Images")

        // 确保目录存在
        try? FileManager.default.createDirectory(
            at: imagesDirectory,
            withIntermediateDirectories: true
        )
    }

    /// 保存图片，返回文件名
    func save(_ image: NSImage) -> String? {
        let fileName = UUID().uuidString + ".png"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(
                  using: .png,
                  properties: [:]
              ) else {
            return nil
        }

        do {
            try pngData.write(to: fileURL)
            return fileName
        } catch {
            print("[ImageStore] 保存失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 读取图片
    func load(fileName: String) -> NSImage? {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        return NSImage(contentsOf: fileURL)
    }

    /// 删除图片
    func delete(fileName: String) {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
