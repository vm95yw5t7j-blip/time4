import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let proProductID = "time4.pro.lifetime"

    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

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

    func refreshEntitlements() async -> Bool {
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else {
                continue
            }

            if transaction.productID == Self.proProductID {
                return true
            }
        }

        return false
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
                return true
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
