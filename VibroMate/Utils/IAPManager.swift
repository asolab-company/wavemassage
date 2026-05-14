import StoreKit

enum PurchaseOutcome {
    case success
    case cancelled
    case pending
    case failed(String)
}

@MainActor
class IAPManager: NSObject, ObservableObject {
    static let shared = IAPManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isSubscribed: Bool = false
    @Published var hasLoadedEntitlements = false
    @Published var productLoadError: String?

    private let productIDs = [Constants.weekly]
    private var transactionUpdatesTask: Task<Void, Never>?

    private override init() {
        super.init()
        observeTransactionUpdates()
        Task {
            await fetchProducts()
            await refreshPurchasedProducts()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    private func updateSubscriptionStatus() {
        isSubscribed =
            purchasedProductIDs.contains(Constants.weekly)
            || purchasedProductIDs.contains(Constants.yearly)
    }

    private func observeTransactionUpdates() {
        transactionUpdatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(transactionResult: result)
            }
        }
    }

    func fetchProducts() async {
        do {
            let result = try await Product.products(for: productIDs)
            products = result.sorted { $0.price < $1.price }
            productLoadError = nil
        } catch {
            productLoadError = error.localizedDescription
        }
    }

    func purchase(product: Product) async -> PurchaseOutcome {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    purchasedProductIDs.insert(transaction.productID)
                    updateSubscriptionStatus()
                    await transaction.finish()
                    await refreshPurchasedProducts()
                    return .success

                case .unverified(_, let error):
                    return .failed(error.localizedDescription)
                }

            case .userCancelled:
                return .cancelled

            case .pending:
                return .pending

            @unknown default:
                return .failed("Unknown purchase result")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {}

        await refreshPurchasedProducts()
    }

    func refreshPurchasedProducts() async {
        var activeProductIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                activeProductIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = activeProductIDs
        updateSubscriptionStatus()
        hasLoadedEntitlements = true
    }

    private func handle(
        transactionResult result: VerificationResult<Transaction>
    ) async {
        switch result {
        case .verified(let transaction):
            await transaction.finish()
            await refreshPurchasedProducts()

        case .unverified:
            break
        }
    }
}
