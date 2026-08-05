import Foundation
import Combine

public final class SnapshotStore: ObservableObject {
    @Published public private(set) var snapshot: Time4Snapshot

    private let defaults: UserDefaults
    private let key: String

    public init(
        defaults: UserDefaults = .standard,
        key: String = "time4.snapshot"
    ) {
        self.defaults = defaults
        self.key = key
        self.snapshot = Self.load(defaults: defaults, key: key)
    }

    public func save(presets: [Preset], isProUnlocked: Bool) {
        let next = Time4Snapshot(presets: presets, isProUnlocked: isProUnlocked)
        snapshot = next

        guard let data = try? JSONEncoder.time4.encode(next) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    private static func load(defaults: UserDefaults, key: String) -> Time4Snapshot {
        guard
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder.time4.decode(Time4Snapshot.self, from: data)
        else {
            return Time4Snapshot(presets: Time4SampleData.defaultPresets, isProUnlocked: false)
        }

        return decoded
    }
}

private extension JSONEncoder {
    static var time4: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var time4: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
