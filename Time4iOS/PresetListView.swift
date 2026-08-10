import SwiftUI
import Time4Shared

struct PresetListView: View {
    @EnvironmentObject private var model: PresetListModel
    @State private var editingPreset: Preset?
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.presets) { preset in
                    NavigationLink {
                        TimerGridPhoneView(presetID: preset.id)
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
                    .swipeActions(edge: .leading) {
                        Button {
                            editingPreset = preset
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                }
                .onDelete(perform: model.delete)
                .onMove(perform: model.move)
            }
            .environment(\.editMode, $editMode)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Time4")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if model.isProUnlocked && model.presets.count > 1 {
                        Button {
                            withAnimation {
                                editMode = editMode.isEditing ? .inactive : .active
                            }
                        } label: {
                            Image(systemName: editMode.isEditing ? "checkmark" : "arrow.up.arrow.down")
                        }
                        .accessibilityLabel(editMode.isEditing ? "並び替えを完了" : "プリセットを並び替え")
                    }
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
