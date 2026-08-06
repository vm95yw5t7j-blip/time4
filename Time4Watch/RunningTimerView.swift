import SwiftUI
import Time4Shared

struct RunningTimerView: View {
    @EnvironmentObject private var model: WatchTimerModel
    let timer: RunningTimer

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text(timer.presetName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(timer.displayName)
                    .font(.headline)
                    .lineLimit(1)
            }

            Text(format(timer.remainingSeconds()))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())

            Button {
                timer.state == .paused ? model.resume() : model.pause()
            } label: {
                Image(systemName: timer.state == .paused ? "play.fill" : "pause.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                model.stop()
            } label: {
                Label("終了", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 6)
    }

    private func format(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let rest = seconds % 60
        return "\(minutes):" + String(format: "%02d", rest)
    }
}
