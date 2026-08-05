import SwiftUI
import Time4Shared

struct TimerGridWatchView: View {
    @EnvironmentObject private var model: WatchTimerModel
    let preset: Preset

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(preset.timers) { timer in
                    Button {
                        model.start(preset: preset, timer: timer)
                    } label: {
                        VStack(spacing: 4) {
                            if !timer.name.isEmpty {
                                Text(timer.name)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            Text(timer.displayDuration)
                                .font(.title3.bold())
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 70)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(preset.name)
    }
}
