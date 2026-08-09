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
                    timerTile(for: timer)
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(preset.name)
    }

    @ViewBuilder
    private func timerTile(for timer: TimerItem) -> some View {
        let runningTimer = activeTimer(for: timer)
        let anotherTimerIsActive = model.runningTimer != nil && runningTimer == nil

        ZStack(alignment: .topTrailing) {
            Button {
                handleTap(timer: timer, runningTimer: runningTimer)
            } label: {
                Group {
                    if let runningTimer {
                        RunningWatchTimerTile(timer: runningTimer)
                    } else {
                        Text(timer.displayDuration)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(Color(white: 0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(anotherTimerIsActive || runningTimer?.state == .finished)

            if runningTimer?.state == .paused {
                Button(role: .destructive) {
                    model.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .frame(width: 20, height: 20)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(3)
                .accessibilityLabel("タイマーを終了")
            }
        }
        .opacity(anotherTimerIsActive ? 0.35 : 1)
    }

    private func activeTimer(for timer: TimerItem) -> RunningTimer? {
        guard
            let runningTimer = model.runningTimer,
            runningTimer.presetID == preset.id,
            runningTimer.timerID == timer.id
        else {
            return nil
        }

        return runningTimer
    }

    private func handleTap(timer: TimerItem, runningTimer: RunningTimer?) {
        guard let runningTimer else {
            model.start(preset: preset, timer: timer)
            return
        }

        switch runningTimer.state {
        case .running:
            model.pause()
        case .paused:
            model.resume()
        case .finished:
            break
        }
    }
}

private struct RunningWatchTimerTile: View {
    let timer: RunningTimer

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.10), lineWidth: 5)

            Circle()
                .trim(from: 0, to: remainingFraction)
                .stroke(
                    timer.state == .paused ? Color.yellow : Color.orange,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: timer.remainingSeconds())

            Text(format(timer.remainingSeconds()))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .minimumScaleFactor(0.55)
                .lineLimit(1)
                .padding(9)
                .contentTransition(.numericText())
        }
        .frame(width: 58, height: 58)
    }

    private var remainingFraction: CGFloat {
        guard timer.durationSeconds > 0 else {
            return 0
        }

        return max(0, min(1, CGFloat(timer.remainingSeconds()) / CGFloat(timer.durationSeconds)))
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
