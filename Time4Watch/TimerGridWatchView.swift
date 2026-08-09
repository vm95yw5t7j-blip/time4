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
                        Text(timer.displayDuration)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(Color(white: 0.12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(preset.name)
    }
}
