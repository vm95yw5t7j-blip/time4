import SwiftUI
import Time4Shared

struct PresetListView: View {
    @EnvironmentObject private var model: PresetListModel
    @State private var editingPreset: Preset?

    var body: some View {
        if let runningTimer = model.runningTimer {
            RunningTimerPhoneView(timer: runningTimer)
        } else {
            NavigationStack {
                List {
                    Section {
                        ForEach(model.presets) { preset in
                            NavigationLink {
                                TimerGridPhoneView(preset: preset)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: preset.icon)
                                        .frame(width: 28, height: 28)
                                        .foregroundStyle(.orange)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(preset.name)
                                            .font(.headline)
                                        Text(preset.timers.map(\.displayDuration).joined(separator: " / "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .contextMenu {
                                Button {
                                    editingPreset = preset
                                } label: {
                                    Label("編集", systemImage: "pencil")
                                }
                            }
                        }
                        .onDelete(perform: model.delete)
                        .onMove(perform: model.move)
                    } footer: {
                        Text(model.isProUnlocked ? "Pro: プリセット無制限" : "無料版はプリセット1つまで。iPhoneでもApple Watchでもワンタップで開始できます。")
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .navigationTitle("Time4")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            model.addPreset()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("プリセットを追加")
                    }
                }
                .sheet(item: $editingPreset) { preset in
                    PresetEditorView(preset: preset)
                }
                .sheet(isPresented: $model.showingPaywall) {
                    ProPaywallView()
                        .environmentObject(model)
                }
            }
        }
    }
}
