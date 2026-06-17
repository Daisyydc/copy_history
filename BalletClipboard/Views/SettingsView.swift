import SwiftUI

/// 设置面板
struct SettingsView: View {
    @State private var retentionDays: Int
    @State private var launchAtLogin: Bool = false

    init() {
        let saved = UserDefaults.standard.integer(forKey: "retentionDays")
        _retentionDays = State(initialValue: saved > 0 ? saved : 3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("⚙️ 设置")
                .font(.system(size: 14, weight: .semibold))

            // 保留期限
            VStack(alignment: .leading, spacing: 8) {
                Text("保留期限")
                    .font(.system(size: 13))

                Picker("", selection: $retentionDays) {
                    Text("1 天").tag(1)
                    Text("3 天").tag(3)
                    Text("5 天").tag(5)
                }
                .pickerStyle(.segmented)
                .onChange(of: retentionDays) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "retentionDays")
                }
            }

            // 开机启动
            Toggle("开机自动启动", isOn: $launchAtLogin)
                .font(.system(size: 13))

            Divider()

            Text("Ballet Clipboard v1.0")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(16)
        .frame(width: 300, height: 250)
    }
}
