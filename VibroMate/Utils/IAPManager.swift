import StoreKit

class IAPManager: NSObject, ObservableObject {
    static let shared = IAPManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isSubscribed: Bool = false

    private override init() {
        super.init()
        Task {
            await fetchProducts()
            await restorePurchases()
        }
    }

    private func updateSubscriptionStatus() {
        isSubscribed =
            purchasedProductIDs.contains(Constants.weekly)
            || purchasedProductIDs.contains(Constants.yearly)
    }

    func fetchProducts() async {
        do {
            let result = try await Product.products(for: [
                Constants.weekly,
                Constants.yearly,
            ])
            await MainActor.run {
                self.products = result
            }
        } catch {
            print("Failed to fetch products:", error)
        }
    }

    func purchase(product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await MainActor.run {
                    self.purchasedProductIDs.insert(product.id)
                    self.updateSubscriptionStatus()
                }
            case .unverified(_, let error):
                print("Unverified purchase:", error)
            }
        default:
            break
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await MainActor.run {
                    self.purchasedProductIDs.insert(transaction.productID)
                }
            }
        }
        await MainActor.run {
            self.updateSubscriptionStatus()
        }
    }
}
