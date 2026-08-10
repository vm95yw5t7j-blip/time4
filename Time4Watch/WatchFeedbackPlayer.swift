import AVFoundation
import WatchKit

@MainActor
final class WatchFeedbackPlayer {
    static let shared = WatchFeedbackPlayer()

    private var player: AVAudioPlayer?

    private init() {}

    func play(soundEnabled: Bool, hapticEnabled: Bool) {
        if hapticEnabled {
            WKInterfaceDevice.current().play(.notification)
        }

        guard
            soundEnabled,
            let url = Bundle.main.url(forResource: "time4-finished", withExtension: "wav")
        else {
            return
        }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
}
