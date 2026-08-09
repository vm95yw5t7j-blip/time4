import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject private var model: WatchTimerModel

    var body: some View {
        PresetListWatchView()
    }
}
