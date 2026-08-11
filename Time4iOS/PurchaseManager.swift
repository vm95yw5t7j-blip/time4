import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let proProductID = "time4.pro.lifetime"

    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published private(set) var isProUnlocked = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private var hasStarted = false

    deinit {
        updatesTask?.cancel()
    }

    var japanesePriceText: String {
        guard let product else {
            return "500円"
        }

        let displayPrice = product.displayPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        if product.price == 0 || displayPrice.contains("0.00") {
            return "500円"
        }
        if displayPrice.hasSuffix("円") {
            return displayPrice
        }

        if displayPrice.hasPrefix("¥") || displayPrice.hasPrefix("￥") {
            let amount = String(displayPrice.dropFirst())
            return amount == "0" ? "500円" : "\(amount)円"
        }

        return displayPrice.contains("$") ? "500円" : displayPrice
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            product = try await Product.products(for: [Self.proProductID]).first
        } catch {
            errorMessage = "購入情報を読み込めませんでした。"
        }
    }

    func start() async {
        guard !hasStarted else {
            return
        }
        hasStarted = true

        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else {
                    return
                }
                guard case .verified(let transaction) = result else {
                    continue
                }
                if transaction.productID == Self.proProductID {
                    await transaction.finish()
                    _ = await refreshEntitlements()
                }
            }
        }

        await load()
        _ = await refreshEntitlements()
    }

    func refreshEntitlements() async -> Bool {
        var unlocked = false
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else {
                continue
            }

            if transaction.productID == Self.proProductID {
                unlocked = true
                break
            }
        }

        isProUnlocked = unlocked
        return unlocked
    }

    func purchasePro() async -> Bool {
        if product == nil {
            await load()
        }

        guard let product else {
            errorMessage = "購入情報を読み込めませんでした。"
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(.verified(let transaction)):
                await transaction.finish()
                return await refreshEntitlements()
            case .success(.unverified), .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "購入を完了できませんでした。"
            return false
        }
    }

    func restore() async -> Bool {
        do {
            try await AppStore.sync()
            return await refreshEntitlements()
        } catch {
            errorMessage = "購入を復元できませんでした。"
            return false
        }
    }
}
