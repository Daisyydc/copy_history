import SwiftUI

/// 弹窗主容器 (360×500) — 芭蕾粉色主题
struct ContentView: View {
    @EnvironmentObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 顶部品牌栏
            headerView

            // 搜索栏
            SearchBarView(text: $viewModel.searchText)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .padding(.bottom, 6)

            // 列表
            if viewModel.filteredItems.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(viewModel.filteredItems, id: \.objectID) { entry in
                            ClipCardView(entry: entry) {
                                viewModel.copyToClipboard(entry)
                            }
                            .transition(
                                .opacity
                                .combined(with: .move(edge: .top))
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .animation(.easeOut(duration: 0.2), value: viewModel.filteredItems.count)
            }
        }
        .frame(width: 360, height: 500)
        .background(BalletTheme.warmWhite)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 8) {
            Text("🩰")
                .font(.system(size: 20))

            Text("Ballet Clipboard")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.831, green: 0.471, blue: 0.561))

            Spacer()

            Text("\(viewModel.items.count) 条")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            BalletTheme.headerGradient
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardViewModel())
}
