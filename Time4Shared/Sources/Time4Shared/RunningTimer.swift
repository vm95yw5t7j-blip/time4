import Foundation

public struct RunningTimer: Codable, Equatable, Sendable {
    public enum State: String, Codable, Sendable {
        case running
        case paused
        case finished
    }

    public enum ExecutionDevice: String, Codable, Sendable {
        case iPhone
        case appleWatch
    }

    public var presetID: UUID
    public var presetName: String
    public var timerID: UUID
    public var timerName: String
    public var durationSeconds: Int
    public var startedAt: Date
    public var endsAt: Date
    public var pausedRemainingSeconds: Int?
    public var state: State
    public var executionDevice: ExecutionDevice
    public var hapticEnabled: Bool
    public var soundEnabled: Bool

    public init(
        preset: Preset,
        timer: TimerItem,
        executionDevice: ExecutionDevice = .iPhone,
        now: Date = .now
    ) {
        self.presetID = preset.id
        self.presetName = preset.name
        self.timerID = timer.id
        self.timerName = timer.name
        self.durationSeconds = timer.durationSeconds
        self.startedAt = now
        self.endsAt = now.addingTimeInterval(TimeInterval(timer.durationSeconds))
        self.pausedRemainingSeconds = nil
        self.state = .running
        self.executionDevice = executionDevice
        self.hapticEnabled = timer.hapticEnabled
        self.soundEnabled = timer.soundEnabled
    }

    public func remainingSeconds(now: Date = .now) -> Int {
        switch state {
        case .running:
            return max(0, Int(ceil(endsAt.timeIntervalSince(now))))
        case .paused:
            return max(0, pausedRemainingSeconds ?? 0)
        case .finished:
            return 0
        }
    }

    public var displayName: String {
        timerName.isEmpty ? presetName : timerName
    }
}

public struct TimerEngine: Sendable {
    public init() {}

    public func pause(_ timer: RunningTimer, now: Date = .now) -> RunningTimer {
        var next = timer
        next.pausedRemainingSeconds = timer.remainingSeconds(now: now)
        next.state = .paused
        return next
    }

    public func resume(_ timer: RunningTimer, now: Date = .now) -> RunningTimer {
        var next = timer
        let remaining = timer.remainingSeconds(now: now)
        next.endsAt = now.addingTimeInterval(TimeInterval(remaining))
        next.pausedRemainingSeconds = nil
        next.state = remaining > 0 ? .running : .finished
        return next
    }

    public func addSeconds(_ seconds: Int, to timer: RunningTimer, now: Date = .now) -> RunningTimer {
        var next = timer
        switch timer.state {
        case .running:
            next.endsAt = timer.endsAt.addingTimeInterval(TimeInterval(seconds))
            if next.remainingSeconds(now: now) <= 0 {
                next.state = .finished
            }
        case .paused:
            next.pausedRemainingSeconds = max(0, (timer.pausedRemainingSeconds ?? 0) + seconds)
        case .finished:
            break
        }
        return next
    }

    public func refresh(_ timer: RunningTimer, now: Date = .now) -> RunningTimer {
        var next = timer
        if timer.state == .running && timer.remainingSeconds(now: now) == 0 {
            next.state = .finished
        }
        return next
    }
}
