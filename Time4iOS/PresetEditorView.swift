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

                Section("タイマーの時間") {
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("タイマー\(number)")
                    .font(.headline)
                Spacer()
                Text(formattedDuration)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.orange)
            }

            Stepper(value: minutes, in: 0...599) {
                LabeledContent("分") {
                    Text("\(timer.durationSeconds / 60)")
                        .font(.title3.bold())
                        .monospacedDigit()
                }
            }

            Stepper(value: seconds, in: 0...59) {
                LabeledContent("秒") {
                    Text("\(timer.durationSeconds % 60)")
                        .font(.title3.bold())
                        .monospacedDigit()
                }
            }

            Divider()
            Toggle("触覚通知", isOn: $timer.hapticEnabled)
            Toggle("通知音", isOn: $timer.soundEnabled)
        }
        .padding(.vertical, 8)
    }

    private var formattedDuration: String {
        String(format: "%d:%02d", timer.durationSeconds / 60, timer.durationSeconds % 60)
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
