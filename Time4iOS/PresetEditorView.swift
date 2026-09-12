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
                    if model.isProUnlocked {
                        Picker("アイコン", selection: $preset.icon) {
                            ForEach(iconChoices) { choice in
                                Label(choice.name, systemImage: choice.symbol)
                                    .tag(choice.symbol)
                            }
                        }
                    } else {
                        HStack {
                            Text("アイコン")
                            Spacer()
                            Label("Pro", systemImage: "lock")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("タイマーの時間") {
                    ForEach(Array(preset.timers.indices), id: \.self) { index in
                        TimerEditorRow(
                            number: index + 1,
                            isPhoneOnly: !watchPreviewTimers.contains(where: { $0.id == preset.timers[index].id }),
                            timer: $preset.timers[index]
                        )
                    }
                }

                Section {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                        spacing: 8
                    ) {
                        ForEach(watchPreviewTimers) { timer in
                            Text(String(format: "%d:%02d", timer.durationSeconds / 60, timer.durationSeconds % 60))
                                .font(.system(.headline, design: .rounded))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .foregroundStyle(.orange)
                                .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: 240)
                    .frame(maxWidth: .infinity)
                } header: {
                    Text("Apple Watchプレビュー")
                } footer: {
                    Text("Apple Watchには先頭の\(Time4Policy.watchTimersPerPreset)個のタイマーが表示されます。")
                }
            }
            .contentMargins(.top, 6, for: .scrollContent)
            .listSectionSpacing(12)
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("キャンセル")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        normalizeTimerOrder()
                        preset.updatedAt = .now
                        model.update(preset)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel("保存")
                    .disabled(preset.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var watchPreviewTimers: [TimerItem] {
        Array(preset.timers.sorted().prefix(Time4Policy.watchTimersPerPreset))
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
    let isPhoneOnly: Bool
    @Binding var timer: TimerItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("タイマー\(number)")
                    .font(.subheadline.weight(.semibold))
                if isPhoneOnly {
                    Text("iPhoneのみ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 7) {
                timeField(value: minutes, placeholder: "0")
                Text("分")
                timeField(value: seconds, placeholder: "00")
                Text("秒")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Toggle(isOn: $timer.hapticEnabled) {
                    Label("振動", systemImage: "iphone.radiowaves.left.and.right")
                }
                .font(.caption)

                Spacer()

                Toggle(isOn: $timer.soundEnabled) {
                    Label("音", systemImage: "speaker.wave.2")
                }
                .font(.caption)

                Button {
                    TimerFeedbackPlayer.play(
                        soundEnabled: timer.soundEnabled,
                        hapticEnabled: timer.hapticEnabled
                    )
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .disabled(!timer.soundEnabled && !timer.hapticEnabled)
                .accessibilityLabel("音と振動を確認")
            }
        }
        .padding(.vertical, 2)
    }

    private func timeField(value: Binding<Int>, placeholder: String) -> some View {
        TextField(placeholder, value: value, format: .number)
            .keyboardType(.numberPad)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
            .frame(width: 62, height: 36)
            .background(Color(white: 0.12))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.orange, lineWidth: 2)
            }
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
