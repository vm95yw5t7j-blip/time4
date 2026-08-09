import Foundation
import SwiftUI
import Time4Shared
import UserNotifications
import WatchConnectivity
import WatchKit

@MainActor
final class WatchTimerModel: NSObject, ObservableObject {
    @Published var presets: [Preset]
    @Published var runningTimer: RunningTimer?

    private let store = SnapshotStore()
    private let engine = TimerEngine()
    private var tickTask: Task<Void, Never>?
    private let runningKey = "time4.runningTimer"

    override init() {
        presets = store.snapshot.presets
        runningTimer = Self.loadRunningTimer(key: runningKey)
        super.init()
        startWatchConnectivity()
        requestNotificationPermission()
        startTicker()
    }

    deinit {
        tickTask?.cancel()
    }

    func start(preset: Preset, timer: TimerItem) {
        guard runningTimer == nil else {
            return
        }

        runningTimer = RunningTimer(preset: preset, timer: timer, executionDevice: .appleWatch)
        persistRunningTimer()
        scheduleNotification(for: timer)
    }

    func pause() {
        guard let runningTimer else {
            return
        }
        self.runningTimer = engine.pause(runningTimer)
        persistRunningTimer()
        cancelTimerNotification()
    }

    func resume() {
        guard let runningTimer else {
            return
        }
        self.runningTimer = engine.resume(runningTimer)
        persistRunningTimer()
        rescheduleNotificationFromRunningTimer()
    }

    func stop() {
        runningTimer = nil
        UserDefaults.standard.removeObject(forKey: runningKey)
        cancelTimerNotification()
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
        guard let current = runningTimer else {
            return
        }

        let refreshed = engine.refresh(current)
        let didFinish = current.state != .finished && refreshed.state == .finished
        runningTimer = refreshed
        persistRunningTimer()

        if didFinish && refreshed.hapticEnabled {
            WKInterfaceDevice.current().play(.notification)
        }

        if didFinish {
            resetFinishedTimer(after: .seconds(1), timerID: refreshed.timerID)
        }
    }

    private func resetFinishedTimer(after delay: Duration, timerID: UUID) {
        Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard self?.runningTimer?.timerID == timerID, self?.runningTimer?.state == .finished else {
                return
            }
            self?.stop()
        }
    }

    private func persistRunningTimer() {
        guard let runningTimer else {
            return
        }

        if let data = try? JSONEncoder.time4Watch.encode(runningTimer) {
            UserDefaults.standard.set(data, forKey: runningKey)
        }
    }

    private func scheduleNotification(for timer: TimerItem) {
        guard timer.soundEnabled || timer.hapticEnabled else {
            return
        }

        cancelTimerNotification()

        let content = UNMutableNotificationContent()
        content.title = "Time4"
        content.body = "タイマーが終了しました"
        content.sound = timer.soundEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer.durationSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func rescheduleNotificationFromRunningTimer() {
        cancelTimerNotification()
        guard
            let runningTimer,
            runningTimer.state == .running,
            runningTimer.soundEnabled || runningTimer.hapticEnabled
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time4"
        content.body = "\(runningTimer.presetName)のタイマーが終了しました"
        content.sound = runningTimer.soundEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(max(1, runningTimer.remainingSeconds())),
            repeats: false
        )
        let request = UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private static func loadRunningTimer(key: String) -> RunningTimer? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder.time4Watch.decode(RunningTimer.self, from: data)
        else {
            return nil
        }

        return TimerEngine().refresh(decoded)
    }

    private static let notificationID = "time4.watch.timer.finished"
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
