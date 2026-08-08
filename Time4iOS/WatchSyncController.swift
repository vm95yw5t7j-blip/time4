import Foundation
import OSLog
import Time4Shared
import WatchConnectivity

final class WatchSyncController: NSObject, WCSessionDelegate {
    private let session: WCSession? = WCSession.isSupported() ? .default : nil
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Time4",
        category: "WatchSync"
    )
    private var latestSnapshot: Time4Snapshot?

    func start() {
        session?.delegate = self
        session?.activate()
    }

    func send(_ snapshot: Time4Snapshot) {
        latestSnapshot = snapshot
        sendLatestSnapshot()
    }

    private func sendLatestSnapshot() {
        guard
            let session,
            session.activationState == .activated,
            let latestSnapshot
        else {
            return
        }

        do {
            let message = try WatchSyncCodec.encodeSnapshot(latestSnapshot)
            try session.updateApplicationContext(message)
        } catch {
            logger.error("Preset sync deferred: \(error.localizedDescription, privacy: .public)")
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated, error == nil else {
            return
        }
        sendLatestSnapshot()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        sendLatestSnapshot()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        guard session.isReachable else {
            return
        }
        sendLatestSnapshot()
    }
}
