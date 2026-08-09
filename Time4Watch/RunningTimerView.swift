import SwiftUI
import Time4Shared

struct RunningTimerView: View {
    @EnvironmentObject private var model: WatchTimerModel
    let timer: RunningTimer

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 5) {
                Text(timer.presetName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 7)

                    Circle()
                        .trim(from: 0, to: remainingFraction)
                        .stroke(
                            timer.state == .paused ? Color.yellow : Color.orange,
                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.25), value: timer.remainingSeconds())

                    Text(format(timer.remainingSeconds()))
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                        .contentTransition(.numericText())
                        .padding(14)
                }
                .frame(width: 92, height: 92)

                HStack(spacing: 8) {
                    Button {
                        timer.state == .paused ? model.resume() : model.pause()
                    } label: {
                        Image(systemName: timer.state == .paused ? "play.fill" : "pause.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .foregroundStyle(.black)
                    .disabled(timer.state == .finished)

                    Button(role: .destructive) {
                        model.stop()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 6)
        }
    }

    private var remainingFraction: CGFloat {
        guard timer.durationSeconds > 0 else {
            return 0
        }

        let remaining = CGFloat(timer.remainingSeconds())
        return max(0, min(1, remaining / CGFloat(timer.durationSeconds)))
    }

    private func format(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let rest = seconds % 60
        return "\(minutes):" + String(format: "%02d", rest)
    }
}
