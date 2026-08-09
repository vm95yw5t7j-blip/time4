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
                        Text(timer.displayDuration)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 142)
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
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
