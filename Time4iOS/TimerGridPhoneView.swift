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
                    timerTile(for: timer)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
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
                        RunningTimerTile(timer: runningTimer)
                    } else {
                        Text(timer.displayDuration)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                    }
                }
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
            .disabled(anotherTimerIsActive || runningTimer?.state == .finished)

            if runningTimer?.state == .paused {
                Button(role: .destructive) {
                    model.stopTimer()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .frame(width: 30, height: 30)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(10)
                .accessibilityLabel("タイマーを終了")
            }
        }
        .opacity(anotherTimerIsActive ? 0.35 : 1)
        .animation(.easeInOut(duration: 0.2), value: anotherTimerIsActive)
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

private struct RunningTimerTile: View {
    let timer: RunningTimer

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.10), lineWidth: 10)

            Circle()
                .trim(from: 0, to: remainingFraction)
                .stroke(
                    timer.state == .paused ? Color.yellow : Color.orange,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: timer.remainingSeconds())

            Text(format(timer.remainingSeconds()))
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
                .padding(18)
                .contentTransition(.numericText())
        }
        .frame(width: 112, height: 112)
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
