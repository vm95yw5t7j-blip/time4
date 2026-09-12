import SwiftUI
import Time4Shared

struct PresetListView: View {
    @EnvironmentObject private var model: PresetListModel
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var editingPreset: Preset?
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack(path: $model.navigationPath) {
            List {
                ForEach(model.presets) { preset in
                    NavigationLink(value: preset.id) {
                        HStack(spacing: 14) {
                            Image(systemName: preset.icon)
                                .font(.title2)
                                .frame(width: 42, height: 42)
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(preset.name)
                                    .font(.title3.weight(.semibold))
                                Text(preset.timers.map(\.displayDuration).joined(separator: " / "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(minHeight: 68)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
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
            .navigationDestination(for: UUID.self) { presetID in
                if model.presets.contains(where: { $0.id == presetID }) {
                    TimerGridPhoneView(presetID: presetID)
                }
            }
            .environment(\.editMode, $editMode)
            .contentMargins(.top, 4, for: .scrollContent)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Time4")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        if model.isProUnlocked && model.presets.count > 1 {
                            Button {
                                withAnimation {
                                    editMode = editMode.isEditing ? .inactive : .active
                                }
                            } label: {
                                Label(
                                    editMode.isEditing ? "並び替えを完了" : "プリセットを並び替え",
                                    systemImage: editMode.isEditing ? "checkmark" : "arrow.up.arrow.down"
                                )
                            }
                        }

                        if !model.isProUnlocked {
                            Button {
                                model.showingPaywall = true
                            } label: {
                                Label("Time4 Pro", systemImage: "crown")
                            }
                        }

                        Divider()

                        Link(destination: AppLinks.privacyPolicy) {
                            Label("プライバシーポリシー", systemImage: "hand.raised")
                        }
                        Link(destination: AppLinks.support) {
                            Label("サポート", systemImage: "questionmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("メニュー")
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
        .onAppear {
            model.restoreNavigationIfNeeded()
        }
        .task {
            model.activate()
            await purchaseManager.start()
            model.setProUnlocked(purchaseManager.isProUnlocked)
        }
        .onChange(of: purchaseManager.isProUnlocked) { _, isProUnlocked in
            model.setProUnlocked(isProUnlocked)
        }
    }
}
