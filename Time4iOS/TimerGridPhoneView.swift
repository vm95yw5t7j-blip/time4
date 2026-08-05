import SwiftUI
import Time4Shared

struct TimerGridPhoneView: View {
    @EnvironmentObject private var model: PresetListModel
    let preset: Preset

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(preset.timers) { timer in
                    Button {
                        model.start(preset: preset, timer: timer)
                    } label: {
                        VStack(spacing: 8) {
                            if !timer.name.isEmpty {
                                Text(timer.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundStyle(.secondary)
                            }
                            Text(timer.displayDuration)
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 142)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .padding()
        }
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
