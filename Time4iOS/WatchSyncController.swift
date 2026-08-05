import Foundation
import Time4Shared
import WatchConnectivity

final class WatchSyncController: NSObject, WCSessionDelegate {
    private let session: WCSession? = WCSession.isSupported() ? .default : nil

    func start() {
        session?.delegate = self
        session?.activate()
    }

    func send(_ snapshot: Time4Snapshot) {
        guard let session, session.activationState == .activated else {
            return
        }

        do {
            let message = try WatchSyncCodec.encodeSnapshot(snapshot)
            try session.updateApplicationContext(message)
        } catch {
            assertionFailure("Failed to sync Time4 snapshot: \(error)")
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
