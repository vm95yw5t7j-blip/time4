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
            Text("タイマー\(number)")
                .font(.headline)

            HStack(alignment: .center, spacing: 12) {
                Spacer()

                VStack(spacing: 4) {
                    TextField("0", value: minutes, format: .number)
                        .keyboardType(.numberPad)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .frame(width: 92, height: 54)
                        .background(Color(white: 0.12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 2)
                        }
                    Text("分")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(":")
                    .font(.title.bold())
                    .padding(.bottom, 20)

                VStack(spacing: 4) {
                    TextField("00", value: seconds, format: .number)
                        .keyboardType(.numberPad)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .frame(width: 92, height: 54)
                        .background(Color(white: 0.12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 2)
                        }
                    Text("秒")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()
            Toggle("触覚通知", isOn: $timer.hapticEnabled)
            Toggle("通知音", isOn: $timer.soundEnabled)
        }
        .padding(.vertical, 8)
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
