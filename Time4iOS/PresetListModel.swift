import Foundation
import SwiftUI
import Time4Shared
import UserNotifications

@MainActor
final class PresetListModel: ObservableObject {
    @Published var presets: [Preset]
    @Published var isProUnlocked: Bool
    @Published var showingPaywall = false
    @Published var runningTimers: [RunningTimer]

    private let store = SnapshotStore()
    private let sync = WatchSyncController()
    private let timerEngine = TimerEngine()
    private let runningKey = "time4.iphone.runningTimer"
    private var tickTask: Task<Void, Never>?

    init() {
        presets = store.snapshot.presets
        isProUnlocked = store.snapshot.isProUnlocked
        runningTimers = Self.loadRunningTimers(key: runningKey)
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
                    TimerItem(durationSeconds: 60, sortOrder: 0),
                    TimerItem(durationSeconds: 180, sortOrder: 1),
                    TimerItem(durationSeconds: 300, sortOrder: 2),
                    TimerItem(durationSeconds: 600, sortOrder: 3)
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
        guard
            runningTimers.count < Time4Policy.maxTimersPerPreset,
            !runningTimers.contains(where: { $0.timerID == timer.id })
        else {
            return
        }

        let runningTimer = RunningTimer(preset: preset, timer: timer, executionDevice: .iPhone)
        runningTimers.append(runningTimer)
        persistRunningTimers()
        scheduleNotification(for: runningTimer)
    }

    func pause(timerID: UUID) {
        guard let index = runningTimers.firstIndex(where: { $0.timerID == timerID }) else {
            return
        }
        runningTimers[index] = timerEngine.pause(runningTimers[index])
        persistRunningTimers()
        cancelTimerNotification(timerID: timerID)
    }

    func resume(timerID: UUID) {
        guard let index = runningTimers.firstIndex(where: { $0.timerID == timerID }) else {
            return
        }
        runningTimers[index] = timerEngine.resume(runningTimers[index])
        persistRunningTimers()
        scheduleNotification(for: runningTimers[index])
    }

    func stopTimer(timerID: UUID) {
        runningTimers.removeAll(where: { $0.timerID == timerID })
        persistRunningTimers()
        cancelTimerNotification(timerID: timerID)
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
        guard !runningTimers.isEmpty else {
            return
        }

        var finishedTimers: [RunningTimer] = []
        for index in runningTimers.indices {
            let current = runningTimers[index]
            let refreshed = timerEngine.refresh(current)
            runningTimers[index] = refreshed
            if current.state != .finished && refreshed.state == .finished {
                finishedTimers.append(refreshed)
            }
        }
        persistRunningTimers()

        for timer in finishedTimers {
            TimerFeedbackPlayer.play(
                soundEnabled: timer.soundEnabled,
                hapticEnabled: timer.hapticEnabled
            )
            resetFinishedTimer(after: .seconds(1), timerID: timer.timerID)
        }
    }

    private func resetFinishedTimer(after delay: Duration, timerID: UUID) {
        Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard self?.runningTimers.first(where: { $0.timerID == timerID })?.state == .finished else {
                return
            }
            self?.stopTimer(timerID: timerID)
        }
    }

    private func persistRunningTimers() {
        if let data = try? JSONEncoder.time4iOS.encode(runningTimers) {
            UserDefaults.standard.set(data, forKey: runningKey)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
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

    private func notificationID(for timerID: UUID) -> String {
        "\(Self.notificationIDPrefix).\(timerID.uuidString)"
    }

    private static let notificationIDPrefix = "time4.iphone.timer.finished"

    private static func loadRunningTimers(key: String) -> [RunningTimer] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        let decoder = JSONDecoder.time4iOS
        let decoded = (try? decoder.decode([RunningTimer].self, from: data))
            ?? (try? decoder.decode(RunningTimer.self, from: data)).map { [$0] }
            ?? []

        let engine = TimerEngine()
        return decoded.map { engine.refresh($0) }.filter { $0.state != .finished }
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
