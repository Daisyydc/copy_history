import Foundation

/// 剪贴板内容类型
enum ClipType: String, CaseIterable {
    case text
    case image
    case url

    var displayName: String {
        switch self {
        case .text: return "文字"
        case .image: return "图片"
        case .url: return "链接"
        }
    }

    var iconName: String {
        switch self {
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .url: return "link"
        }
    }
}
