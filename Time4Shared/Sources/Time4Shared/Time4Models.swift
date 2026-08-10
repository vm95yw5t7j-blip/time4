import Foundation

public struct Preset: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var icon: String
    public var sortOrder: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var timers: [TimerItem]

    public init(
        id: UUID = UUID(),
        name: String,
        icon: String = "timer",
        sortOrder: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        timers: [TimerItem] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.timers = Array(timers.sorted().prefix(Time4Policy.maxTimersPerPreset))
    }

    public mutating func replaceTimers(_ nextTimers: [TimerItem]) {
        timers = Array(nextTimers.sorted().prefix(Time4Policy.maxTimersPerPreset))
        updatedAt = .now
    }
}

public struct TimerItem: Identifiable, Codable, Equatable, Comparable, Sendable {
    public var id: UUID
    public var durationSeconds: Int
    public var sortOrder: Int
    public var hapticEnabled: Bool
    public var soundEnabled: Bool

    public init(
        id: UUID = UUID(),
        durationSeconds: Int,
        sortOrder: Int = 0,
        hapticEnabled: Bool = true,
        soundEnabled: Bool = false
    ) {
        self.id = id
        self.durationSeconds = max(1, durationSeconds)
        self.sortOrder = sortOrder
        self.hapticEnabled = hapticEnabled
        self.soundEnabled = soundEnabled
    }

    public static func < (lhs: TimerItem, rhs: TimerItem) -> Bool {
        lhs.sortOrder == rhs.sortOrder ? lhs.durationSeconds < rhs.durationSeconds : lhs.sortOrder < rhs.sortOrder
    }
}

public struct Time4Snapshot: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var presets: [Preset]
    public var isProUnlocked: Bool
    public var updatedAt: Date

    public init(
        schemaVersion: Int = 1,
        presets: [Preset],
        isProUnlocked: Bool,
        updatedAt: Date = .now
    ) {
        self.schemaVersion = schemaVersion
        self.presets = presets.sorted { $0.sortOrder < $1.sortOrder }
        self.isProUnlocked = isProUnlocked
        self.updatedAt = updatedAt
    }
}

public extension TimerItem {
    var displayDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60

        if minutes == 0 {
            return "\(seconds)秒"
        }

        if seconds == 0 {
            return "\(minutes)分"
        }

        return "\(minutes)分\(seconds)秒"
    }
}
