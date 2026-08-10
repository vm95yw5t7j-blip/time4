import AudioToolbox
import UIKit

@MainActor
enum TimerFeedbackPlayer {
    private static let soundID: SystemSoundID? = {
        guard let url = Bundle.main.url(forResource: "time4-finished", withExtension: "wav") else {
            return nil
        }

        var soundID: SystemSoundID = 0
        guard AudioServicesCreateSystemSoundID(url as CFURL, &soundID) == kAudioServicesNoError else {
            return nil
        }
        return soundID
    }()

    static func play(soundEnabled: Bool, hapticEnabled: Bool) {
        if hapticEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }

        if soundEnabled, let soundID {
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
