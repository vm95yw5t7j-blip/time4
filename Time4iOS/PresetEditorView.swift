import Foundation
import SwiftUI
import Time4Shared

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: PresetListModel

    @State private var preset: Preset

    init(preset: Preset) {
        _preset = State(initialValue: preset)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("プリセット") {
                    TextField("名前", text: $preset.name)
                    Picker("アイコン", selection: $preset.icon) {
                        ForEach(iconChoices) { choice in
                            Label(choice.name, systemImage: choice.symbol)
                                .tag(choice.symbol)
                        }
                    }
                }

                Section("Apple Watch表示") {
                    WatchPreviewGrid(timers: preset.timers)
                }

                Section("タイマー") {
                    ForEach(Array(preset.timers.indices), id: \.self) { index in
                        TimerEditorRow(
                            number: index + 1,
                            timer: $preset.timers[index]
                        )
                    }
                }
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        normalizeTimerOrder()
                        preset.updatedAt = .now
                        model.update(preset)
                        dismiss()
                    }
                    .disabled(preset.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var iconChoices: [IconChoice] {
        [
            IconChoice(symbol: "timer", name: "タイマー"),
            IconChoice(symbol: "figure.strengthtraining.traditional", name: "筋トレ"),
            IconChoice(symbol: "fork.knife", name: "料理"),
            IconChoice(symbol: "cup.and.saucer", name: "コーヒー"),
            IconChoice(symbol: "book", name: "勉強"),
            IconChoice(symbol: "hammer", name: "作業"),
            IconChoice(symbol: "figure.cooldown", name: "ストレッチ")
        ]
    }

    private func normalizeTimerOrder() {
        for index in preset.timers.indices {
            preset.timers[index].sortOrder = index
        }
    }
}

private struct IconChoice: Identifiable {
    let symbol: String
    let name: String

    var id: String { symbol }
}

private struct TimerEditorRow: View {
    let number: Int
    @Binding var timer: TimerItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("タイマー\(number)")
                .font(.headline)
            HStack {
                Text("時間")
                Spacer()
                TextField("0", value: minutes, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 48)
                Text("分")
                TextField("0", value: seconds, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 40)
                Text("秒")
            }
            Toggle("触覚通知", isOn: $timer.hapticEnabled)
            Toggle("通知音", isOn: $timer.soundEnabled)
        }
        .padding(.vertical, 4)
    }

    private var minutes: Binding<Int> {
        Binding(
            get: { timer.durationSeconds / 60 },
            set: { newValue in
                timer.durationSeconds = max(1, min(599, newValue) * 60 + timer.durationSeconds % 60)
            }
        )
    }

    private var seconds: Binding<Int> {
        Binding(
            get: { timer.durationSeconds % 60 },
            set: { newValue in
                timer.durationSeconds = max(1, (timer.durationSeconds / 60) * 60 + min(59, max(0, newValue)))
            }
        )
    }
}

private struct WatchPreviewGrid: View {
    let timers: [TimerItem]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            ForEach(timers) { timer in
                VStack(spacing: 4) {
                    Text(timer.displayDuration)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(Color(white: 0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
