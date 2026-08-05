import Foundation

public enum WatchSyncMessage: String, Codable, Sendable {
    case snapshot
}

public enum WatchSyncCodec {
    public static let snapshotKey = "snapshot"

    public static func encodeSnapshot(_ snapshot: Time4Snapshot) throws -> [String: Any] {
        let data = try JSONEncoder.time4Sync.encode(snapshot)
        return [snapshotKey: data]
    }

    public static func decodeSnapshot(from message: [String: Any]) throws -> Time4Snapshot {
        guard let data = message[snapshotKey] as? Data else {
            throw WatchSyncCodecError.missingSnapshot
        }
        return try JSONDecoder.time4Sync.decode(Time4Snapshot.self, from: data)
    }
}

public enum WatchSyncCodecError: Error {
    case missingSnapshot
}

private extension JSONEncoder {
    static var time4Sync: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var time4Sync: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
