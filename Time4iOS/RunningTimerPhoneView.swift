import SwiftUI
import Time4Shared

struct RunningTimerPhoneView: View {
    @EnvironmentObject private var model: PresetListModel
    let timer: RunningTimer

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text(timer.presetName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(timer.displayName)
                    .font(.title2.bold())
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)

            Text(format(timer.remainingSeconds()))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.65)
                .contentTransition(.numericText())

            Button {
                timer.state == .paused ? model.resume() : model.pause()
            } label: {
                Label(timer.state == .paused ? "再開" : "一時停止", systemImage: timer.state == .paused ? "play.fill" : "pause.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Button(role: .destructive) {
                model.stopTimer()
            } label: {
                Label("終了", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
        }
        .padding()
    }

    private var progress: Double {
        guard timer.durationSeconds > 0 else {
            return 1
        }

        let remaining = Double(timer.remainingSeconds())
        return max(0, min(1, 1 - remaining / Double(timer.durationSeconds)))
    }

    private func format(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let rest = seconds % 60
        return "\(minutes):" + String(format: "%02d", rest)
    }
}
