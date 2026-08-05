import SwiftUI
import Time4Shared

struct PresetListWatchView: View {
    @EnvironmentObject private var model: WatchTimerModel

    var body: some View {
        NavigationStack {
            List(model.presets) { preset in
                NavigationLink {
                    TimerGridWatchView(preset: preset)
                } label: {
                    Label(preset.name, systemImage: preset.icon)
                        .font(.headline)
                }
            }
            .navigationTitle("Time4")
        }
    }
}
