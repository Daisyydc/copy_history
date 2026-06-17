import SwiftUI

/// 单条剪贴板记录卡片 — 芭蕾风格
struct ClipCardView: View {
    let entry: ClipboardEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // 左侧类型图标
                typeIconView

                // 中间内容预览
                VStack(alignment: .leading, spacing: 4) {
                    Text(previewText)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(relativeTime)
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.557, green: 0.557, blue: 0.576))
                }

                Spacer()

                // 右侧复制提示
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(BalletTheme.deepPink.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: BalletTheme.balletPink.opacity(0.15), radius: 2, x: 0, y: 1)
            )
            .overlay(
                // 置顶金色左边框
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        entry.isPinned ? BalletTheme.gold : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Type Icon

    @ViewBuilder
    private var typeIconView: some View {
        switch entry.contentType {
        case "image":
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(BalletTheme.lightPink)
                    .frame(width: 36, height: 36)
                Image(systemName: "photo")
                    .font(.system(size: 16))
                    .foregroundColor(BalletTheme.rosePink)
            }
        case "url":
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(BalletTheme.lightPink)
                    .frame(width: 36, height: 36)
                Image(systemName: "link")
                    .font(.system(size: 16))
                    .foregroundColor(BalletTheme.rosePink)
            }
        default:
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(BalletTheme.lightPink)
                    .frame(width: 36, height: 36)
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16))
                    .foregroundColor(BalletTheme.rosePink)
            }
        }
    }

    // MARK: - Helpers

    private var previewText: String {
        if entry.contentType == "image" {
            return "🖼️ 图片"
        }
        if entry.contentType == "url" {
            let text = entry.textContent ?? ""
            // 只显示域名
            if let url = URL(string: text), let host = url.host {
                return "🔗 \(host)"
            }
            return "🔗 \(text)"
        }
        return entry.textContent ?? ""
    }

    private var relativeTime: String {
        guard let timestamp = entry.timestamp else { return "" }
        return RelativeTimeFormatter.format(timestamp)
    }
}
