import SwiftUI
import Time4Shared

@main
struct Time4App: App {
    @StateObject private var model = PresetListModel()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            PresetListView()
                .environmentObject(model)
                .environmentObject(purchaseManager)
                .preferredColorScheme(.dark)
                .tint(.orange)
        }
    }
}
