import SwiftUI

@main
struct BalletClipboardApp: App {
    @StateObject private var viewModel = ClipboardViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 360, minHeight: 500)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 360, height: 500)
    }
}
