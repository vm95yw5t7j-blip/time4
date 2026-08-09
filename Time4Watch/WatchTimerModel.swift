import Foundation
import SwiftUI
import Time4Shared
import UserNotifications
import WatchConnectivity
import WatchKit

@MainActor
final class WatchTimerModel: NSObject, ObservableObject {
    @Published var presets: [Preset]
    @Published var runningTimers: [RunningTimer]

    private let store = SnapshotStore()
    private let engine = TimerEngine()
    private var tickTask: Task<Void, Never>?
    private let runningKey = "time4.runningTimer"

    override init() {
        presets = store.snapshot.presets
        runningTimers = Self.loadRunningTimers(key: runningKey)
        super.init()
        startWatchConnectivity()
        requestNotificationPermission()
        startTicker()
    }

    deinit {
        tickTask?.cancel()
    }

    func start(preset: Preset, timer: TimerItem) {
        guard
            runningTimers.count < Time4Policy.maxTimersPerPreset,
            !runningTimers.contains(where: { $0.timerID == timer.id })
        else {
            return
        }

        let runningTimer = RunningTimer(preset: preset, timer: timer, executionDevice: .appleWatch)
        runningTimers.append(runningTimer)
        persistRunningTimers()
        scheduleNotification(for: runningTimer)
    }

    func pause(timerID: UUID) {
        guard let index = runningTimers.firstIndex(where: { $0.timerID == timerID }) else {
            return
        }
        runningTimers[index] = engine.pause(runningTimers[index])
        persistRunningTimers()
        cancelTimerNotification(timerID: timerID)
    }

    func resume(timerID: UUID) {
        guard let index = runningTimers.firstIndex(where: { $0.timerID == timerID }) else {
            return
        }
        runningTimers[index] = engine.resume(runningTimers[index])
        persistRunningTimers()
        scheduleNotification(for: runningTimers[index])
    }

    func stop(timerID: UUID) {
        runningTimers.removeAll(where: { $0.timerID == timerID })
        persistRunningTimers()
        cancelTimerNotification(timerID: timerID)
    }

    func apply(snapshot: Time4Snapshot) {
        presets = snapshot.presets
        store.save(presets: snapshot.presets, isProUnlocked: snapshot.isProUnlocked)
    }

    private func startTicker() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    self?.refresh()
                }
            }
        }
    }

    private func refresh() {
        guard !runningTimers.isEmpty else {
            return
        }

        var finishedTimers: [RunningTimer] = []
        for index in runningTimers.indices {
            let current = runningTimers[index]
            let refreshed = engine.refresh(current)
            runningTimers[index] = refreshed
            if current.state != .finished && refreshed.state == .finished {
                finishedTimers.append(refreshed)
            }
        }
        persistRunningTimers()

        for timer in finishedTimers {
            if timer.hapticEnabled {
                WKInterfaceDevice.current().play(.notification)
            }
            resetFinishedTimer(after: .seconds(1), timerID: timer.timerID)
        }
    }

    private func resetFinishedTimer(after delay: Duration, timerID: UUID) {
        Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard self?.runningTimers.first(where: { $0.timerID == timerID })?.state == .finished else {
                return
            }
            self?.stop(timerID: timerID)
        }
    }

    private func persistRunningTimers() {
        if let data = try? JSONEncoder.time4Watch.encode(runningTimers) {
            UserDefaults.standard.set(data, forKey: runningKey)
        }
    }

    private func scheduleNotification(for runningTimer: RunningTimer) {
        guard
            runningTimer.state == .running,
            runningTimer.soundEnabled || runningTimer.hapticEnabled
        else {
            return
        }

        cancelTimerNotification(timerID: runningTimer.timerID)

        let content = UNMutableNotificationContent()
        content.title = "Time4"
        content.body = "\(runningTimer.presetName)のタイマーが終了しました"
        content.sound = runningTimer.soundEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(max(1, runningTimer.remainingSeconds())),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: notificationID(for: runningTimer.timerID),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelTimerNotification(timerID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationID(for: timerID)]
        )
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private static func loadRunningTimers(key: String) -> [RunningTimer] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        let decoder = JSONDecoder.time4Watch
        let decoded = (try? decoder.decode([RunningTimer].self, from: data))
            ?? (try? decoder.decode(RunningTimer.self, from: data)).map { [$0] }
            ?? []

        let engine = TimerEngine()
        return decoded.map { engine.refresh($0) }.filter { $0.state != .finished }
    }

    private func notificationID(for timerID: UUID) -> String {
        "\(Self.notificationIDPrefix).\(timerID.uuidString)"
    }

    private static let notificationIDPrefix = "time4.watch.timer.finished"
}

extension WatchTimerModel: WCSessionDelegate {
    private func startWatchConnectivity() {
        guard WCSession.isSupported() else {
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        guard let snapshot = try? WatchSyncCodec.decodeSnapshot(from: applicationContext) else {
            return
        }

        Task { @MainActor in
            self.apply(snapshot: snapshot)
        }
    }
}

private extension JSONEncoder {
    static var time4Watch: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var time4Watch: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
