import SwiftUI

struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: PresetListModel
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Time4 Pro")
                    .font(.largeTitle.bold())
                Text("買い切り500円。ずっと使えます。")
                    .font(.headline)
                Divider()
                Label("プリセット無制限", systemImage: "infinity")
                Label("プリセット並び替え", systemImage: "arrow.up.arrow.down")
                Label("アイコン変更", systemImage: "sparkles")
                Label("タイマー名のカスタマイズ", systemImage: "textformat")
                if let errorMessage = purchaseManager.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                Spacer()
                Button {
                    Task {
                        if await purchaseManager.purchasePro() {
                            model.setProUnlocked(true)
                            dismiss()
                        }
                    }
                } label: {
                    Text(purchaseManager.product.map { "購入する \($0.displayPrice)" } ?? "購入する")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(purchaseManager.isLoading)
                Button("購入を復元") {
                    Task {
                        if await purchaseManager.restore() {
                            model.setProUnlocked(true)
                            dismiss()
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await purchaseManager.load()
                if await purchaseManager.refreshEntitlements() {
                    model.setProUnlocked(true)
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}
