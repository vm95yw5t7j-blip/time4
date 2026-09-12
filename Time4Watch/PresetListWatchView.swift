import SwiftUI
import Time4Shared

struct PresetListWatchView: View {
    @EnvironmentObject private var model: WatchTimerModel

    var body: some View {
        NavigationStack(path: $model.navigationPath) {
            List(model.presets) { preset in
                NavigationLink(value: preset.id) {
                    Label(preset.name, systemImage: preset.icon)
                        .font(.headline)
                }
            }
            .navigationTitle("Time4")
            .navigationDestination(for: UUID.self) { presetID in
                if let preset = model.presets.first(where: { $0.id == presetID }) {
                    TimerGridWatchView(preset: preset)
                }
            }
        }
    }
}
