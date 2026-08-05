import Foundation

public enum Time4Policy {
    public static let freePresetLimit = 1
    public static let maxTimersPerPreset = 4
    public static let addSecondsStep = 30

    public static func canCreatePreset(currentCount: Int, isProUnlocked: Bool) -> Bool {
        isProUnlocked || currentCount < freePresetLimit
    }
}

public enum Time4SampleData {
    public static let defaultPresets: [Preset] = [
        Preset(
            name: "筋トレ",
            icon: "figure.strengthtraining.traditional",
            sortOrder: 0,
            timers: [
                TimerItem(name: "短め", durationSeconds: 60, sortOrder: 0),
                TimerItem(name: "通常", durationSeconds: 90, sortOrder: 1),
                TimerItem(name: "長め", durationSeconds: 120, sortOrder: 2),
                TimerItem(name: "最大", durationSeconds: 180, sortOrder: 3)
            ]
        )
    ]
}
