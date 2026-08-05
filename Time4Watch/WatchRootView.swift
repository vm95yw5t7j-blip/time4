import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject private var model: WatchTimerModel

    var body: some View {
        if let runningTimer = model.runningTimer {
            RunningTimerView(timer: runningTimer)
        } else {
            PresetListWatchView()
        }
    }
}
