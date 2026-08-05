import SwiftUI

@main
struct Time4WatchApp: App {
    @StateObject private var model = WatchTimerModel()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(model)
        }
    }
}
