import Foundation
import Combine
#if canImport(StoreKit)
import StoreKit
#endif

@MainActor
public final class PremiumStore: ObservableObject {
    public static let premiumProductID = "com.rainglyph.composer.premium.localpacks"

    @Published public private(set) var isPremiumUnlocked = false
    @Published public private(set) var statusMessage = "Premium local packs are optional. The base rain glyph score flow is free."
    #if canImport(StoreKit)
    @Published public private(set) var products: [Product] = []
    #endif

    public init() {}

    public func loadProducts() async {
        #if canImport(StoreKit)
        do {
            products = try await Product.products(for: [Self.premiumProductID])
            statusMessage = products.isEmpty
                ? "StoreKit products are unavailable in this environment. You can still create rain glyph scores."
                : "Premium Local Packs are available as an optional local visual upgrade."
            await refreshEntitlements()
        } catch {
            statusMessage = "StoreKit is unavailable right now. You can still use the base composer."
        }
        #else
        statusMessage = "StoreKit is unavailable on this platform. You can still create rain glyph scores."
        #endif
    }

    public func purchasePremium() async {
        #if canImport(StoreKit)
        guard let product = products.first else {
            statusMessage = "Premium packs are unavailable in this test environment. Base creation remains free."
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    isPremiumUnlocked = true
                    statusMessage = "Premium Local Packs unlocked on this device."
                    await transaction.finish()
                case .unverified:
                    statusMessage = "Purchase could not be verified. No base feature is blocked."
                }
            case .pending:
                statusMessage = "Purchase is pending. Base composer remains available."
            case .userCancelled:
                statusMessage = "Purchase cancelled. Base composer remains available."
            @unknown default:
                statusMessage = "Purchase state changed. Base composer remains available."
            }
        } catch {
            statusMessage = "Purchase failed. Base composer remains available."
        }
        #else
        statusMessage = "StoreKit is unavailable on this platform. Base composer remains available."
        #endif
    }

    public func restore() async {
        #if canImport(StoreKit)
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = isPremiumUnlocked ? "Premium Local Packs restored." : "No premium purchase found. Base composer remains available."
        } catch {
            statusMessage = "Restore failed. Base composer remains available."
        }
        #else
        statusMessage = "Restore is unavailable on this platform. Base composer remains available."
        #endif
    }

    #if canImport(StoreKit)
    private func refreshEntitlements() async {
        var unlocked = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement, transaction.productID == Self.premiumProductID {
                unlocked = true
            }
        }
        isPremiumUnlocked = unlocked
    }
    #endif
}
