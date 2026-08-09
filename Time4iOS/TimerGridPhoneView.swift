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
            .disabled(runningTimer?.state == .finished)

            if runningTimer?.state == .paused {
                Button(role: .destructive) {
                    model.stopTimer(timerID: timer.id)
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
    }

    private func activeTimer(for timer: TimerItem) -> RunningTimer? {
        model.runningTimers.first {
            $0.presetID == preset.id && $0.timerID == timer.id
        }
    }

    private func handleTap(timer: TimerItem, runningTimer: RunningTimer?) {
        guard let runningTimer else {
            model.start(preset: preset, timer: timer)
            return
        }

        switch runningTimer.state {
        case .running:
            model.pause(timerID: timer.id)
        case .paused:
            model.resume(timerID: timer.id)
        case .finished:
            break
        }
    }
}

private struct RunningTimerTile: View {
    let timer: RunningTimer

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.25)) { context in
            timerRing(now: context.date)
        }
    }

    private func timerRing(now: Date) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.10), lineWidth: 10)

            Circle()
                .trim(from: 0, to: remainingFraction(now: now))
                .stroke(
                    timer.state == .paused ? Color.yellow : Color.orange,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: remainingInterval(now: now))

            Text(format(Int(ceil(remainingInterval(now: now)))))
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

    private func remainingFraction(now: Date) -> CGFloat {
        guard timer.durationSeconds > 0 else {
            return 0
        }

        return max(0, min(1, CGFloat(remainingInterval(now: now)) / CGFloat(timer.durationSeconds)))
    }

    private func remainingInterval(now: Date) -> TimeInterval {
        switch timer.state {
        case .running:
            return max(0, timer.endsAt.timeIntervalSince(now))
        case .paused:
            return TimeInterval(max(0, timer.pausedRemainingSeconds ?? 0))
        case .finished:
            return 0
        }
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
