import SwiftUI
import Time4Shared

@main
struct Time4App: App {
    @StateObject private var model = PresetListModel()

    var body: some Scene {
        WindowGroup {
            PresetListView()
                .environmentObject(model)
        }
    }
}
