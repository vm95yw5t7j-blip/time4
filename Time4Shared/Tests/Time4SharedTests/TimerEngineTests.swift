import XCTest
@testable import Time4Shared

final class TimerEngineTests: XCTestCase {
    func testRunningTimerUsesEndDateForRemainingTime() {
        let start = Date(timeIntervalSince1970: 1_000)
        let preset = Preset(name: "料理", timers: [TimerItem(durationSeconds: 180)])
        let timer = RunningTimer(preset: preset, timer: preset.timers[0], executionDevice: .iPhone, now: start)

        XCTAssertEqual(timer.remainingSeconds(now: start.addingTimeInterval(30)), 150)
    }

    func testPauseAndResumePreservesRemainingTime() {
        let engine = TimerEngine()
        let start = Date(timeIntervalSince1970: 1_000)
        let preset = Preset(name: "現場", timers: [TimerItem(durationSeconds: 300)])
        let timer = RunningTimer(preset: preset, timer: preset.timers[0], executionDevice: .iPhone, now: start)

        let paused = engine.pause(timer, now: start.addingTimeInterval(120))
        let resumed = engine.resume(paused, now: start.addingTimeInterval(200))

        XCTAssertEqual(paused.remainingSeconds(now: start.addingTimeInterval(150)), 180)
        XCTAssertEqual(resumed.remainingSeconds(now: start.addingTimeInterval(200)), 180)
    }

    func testPresetKeepsAtMostFourTimers() {
        let preset = Preset(
            name: "テスト",
            timers: (0..<6).map { TimerItem(durationSeconds: 60 + $0, sortOrder: $0) }
        )

        XCTAssertEqual(preset.timers.count, 4)
    }
}
