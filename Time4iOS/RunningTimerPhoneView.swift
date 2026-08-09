import SwiftUI
import Time4Shared

struct RunningTimerPhoneView: View {
    @EnvironmentObject private var model: PresetListModel
    let timer: RunningTimer

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                Text(timer.presetName)
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.10), lineWidth: 18)

                    Circle()
                        .trim(from: 0, to: remainingFraction)
                        .stroke(
                            timer.state == .paused ? Color.yellow : Color.orange,
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color.orange.opacity(0.30), radius: 10)
                        .animation(.linear(duration: 0.25), value: timer.remainingSeconds())

                    Text(format(timer.remainingSeconds()))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                        .contentTransition(.numericText())
                        .padding(30)
                }
                .frame(width: 280, height: 280)

                Button {
                    timer.state == .paused ? model.resume() : model.pause()
                } label: {
                    Label(
                        timer.state == .paused ? "再開" : "一時停止",
                        systemImage: timer.state == .paused ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .foregroundStyle(.black)
                .disabled(timer.state == .finished)

                Button(role: .destructive) {
                    model.stopTimer()
                } label: {
                    Label(timer.state == .finished ? "閉じる" : "終了", systemImage: "xmark")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
            }
            .padding()
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
