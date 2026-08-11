import SwiftUI

struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: PresetListModel
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Time4 Pro")
                        .font(.title.bold())
                    Text("買い切り500円。ずっと使えます。")
                        .font(.subheadline.weight(.semibold))
                    Divider()
                    VStack(alignment: .leading, spacing: 12) {
                        Label("プリセット無制限", systemImage: "infinity")
                        Label("プリセット並び替え", systemImage: "arrow.up.arrow.down")
                        Label("アイコン変更", systemImage: "sparkles")
                    }
                    if let errorMessage = purchaseManager.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    Button {
                        Task {
                            if await purchaseManager.purchasePro() {
                                model.setProUnlocked(true)
                                dismiss()
                            }
                        }
                    } label: {
                        Text("\(purchaseManager.japanesePriceText)で購入する")
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await purchaseManager.load()
                if await purchaseManager.refreshEntitlements() {
                    model.setProUnlocked(true)
                    dismiss()
                }
            }
            .onChange(of: purchaseManager.isProUnlocked) { _, isUnlocked in
                guard isUnlocked else {
                    return
                }
                model.setProUnlocked(true)
                dismiss()
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
