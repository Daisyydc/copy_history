import SwiftUI

/// 搜索栏 — 芭蕾风格
struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(BalletTheme.rosePink.opacity(0.6))
                .font(.system(size: 13))

            TextField("搜索复制过的内容...", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13))

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(BalletTheme.rosePink.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(BalletTheme.lightPink.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(BalletTheme.balletPink.opacity(0.3), lineWidth: 1)
        )
    }
}
