import SwiftUI

/// 空状态视图 — 芭蕾主题
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // 🩰 芭蕾舞鞋图标
            Text("🩰")
                .font(.system(size: 56))

            Text("等待你的第一次复制")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 0.831, green: 0.471, blue: 0.561))

            Text("试试在任意 App 中按 ⌘C\n复制的文字会出现在这里 ✨")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 30)
    }
}
