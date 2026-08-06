import Foundation
import SwiftUI
import Time4Shared
import UserNotifications

@MainActor
final class PresetListModel: ObservableObject {
    @Published var presets: [Preset]
    @Published var isProUnlocked: Bool
    @Published var showingPaywall = false
    @Published var runningTimer: RunningTimer?

    private let store = SnapshotStore()
    private let sync = WatchSyncController()
    private let timerEngine = TimerEngine()
    private let runningKey = "time4.iphone.runningTimer"
    private var tickTask: Task<Void, Never>?

    init() {
        presets = store.snapshot.presets
        isProUnlocked = store.snapshot.isProUnlocked
        runningTimer = Self.loadRunningTimer(key: runningKey)
        sync.start()
        sync.send(store.snapshot)
        requestNotificationPermission()
        startTicker()
    }

    deinit {
        tickTask?.cancel()
    }

    func addPreset() {
        guard Time4Policy.canCreatePreset(currentCount: presets.count, isProUnlocked: isProUnlocked) else {
            showingPaywall = true
            return
        }

        let nextOrder = (presets.map(\.sortOrder).max() ?? -1) + 1
        presets.append(
            Preset(
                name: "新しいプリセット",
                icon: "timer",
                sortOrder: nextOrder,
                timers: [
                    TimerItem(name: "短め", durationSeconds: 60, sortOrder: 0),
                    TimerItem(name: "通常", durationSeconds: 180, sortOrder: 1),
                    TimerItem(name: "長め", durationSeconds: 300, sortOrder: 2),
                    TimerItem(name: "最大", durationSeconds: 600, sortOrder: 3)
                ]
            )
        )
        persist()
    }

    func delete(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        normalizeSortOrder()
        persist()
    }

    func move(from source: IndexSet, to destination: Int) {
        guard isProUnlocked else {
            showingPaywall = true
            return
        }

        presets.move(fromOffsets: source, toOffset: destination)
        normalizeSortOrder()
        persist()
    }

    func update(_ preset: Preset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else {
            return
        }

        presets[index] = preset
        persist()
    }

    func setProUnlocked(_ unlocked: Bool) {
        guard isProUnlocked != unlocked else {
            return
        }
        isProUnlocked = unlocked
        persist()
    }

    func start(preset: Preset, timer: TimerItem) {
        runningTimer = RunningTimer(preset: preset, timer: timer, executionDevice: .iPhone)
        persistRunningTimer()
        scheduleNotification(for: timer)
    }

    func pause() {
        guard let runningTimer else {
            return
        }
        self.runningTimer = timerEngine.pause(runningTimer)
        persistRunningTimer()
    }

    func resume() {
        guard let runningTimer else {
            return
        }
        self.runningTimer = timerEngine.resume(runningTimer)
        persistRunningTimer()
        rescheduleNotificationFromRunningTimer()
    }

    func stopTimer() {
        runningTimer = nil
        UserDefaults.standard.removeObject(forKey: runningKey)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
    }

    private func normalizeSortOrder() {
        for index in presets.indices {
            presets[index].sortOrder = index
            presets[index].updatedAt = .now
        }
    }

    private func persist() {
        store.save(presets: presets, isProUnlocked: isProUnlocked)
        sync.send(Time4Snapshot(presets: presets, isProUnlocked: isProUnlocked))
    }

    private func startTicker() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    self?.refreshTimer()
                }
            }
        }
    }

    private func refreshTimer() {
        guard let current = runningTimer else {
            return
        }

        runningTimer = timerEngine.refresh(current)
        persistRunningTimer()
    }

    private func persistRunningTimer() {
        guard let runningTimer else {
            return
        }

        if let data = try? JSONEncoder.time4iOS.encode(runningTimer) {
            UserDefaults.standard.set(data, forKey: runningKey)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleNotification(for timer: TimerItem) {
        guard timer.soundEnabled || timer.hapticEnabled else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time4"
        content.body = timer.name.isEmpty ? "タイマーが終了しました" : "\(timer.name) が終了しました"
        content.sound = timer.soundEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer.durationSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func rescheduleNotificationFromRunningTimer() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
        guard
            let runningTimer,
            runningTimer.state == .running,
            runningTimer.soundEnabled || runningTimer.hapticEnabled
        else {
            return
        }

        let seconds = max(1, runningTimer.remainingSeconds())
        let content = UNMutableNotificationContent()
        content.title = "Time4"
        content.body = "\(runningTimer.displayName) が終了しました"
        content.sound = runningTimer.soundEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private static let notificationID = "time4.iphone.timer.finished"

    private static func loadRunningTimer(key: String) -> RunningTimer? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder.time4iOS.decode(RunningTimer.self, from: data)
        else {
            return nil
        }

        return TimerEngine().refresh(decoded)
    }
}

private extension JSONEncoder {
    static var time4iOS: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var time4iOS: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
