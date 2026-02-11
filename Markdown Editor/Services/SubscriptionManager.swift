//
//  SubscriptionManager.swift
//  Markdown Editor
//
//  Manages StoreKit 2 subscription state for Mac MD Premium.
//  Use as a singleton injected via the SwiftUI environment.
//

import StoreKit
import SwiftUI
import Observation

/// Product identifiers for Mac MD Premium subscriptions.
enum PremiumProductID {
    static let monthly = "com.ahammock.macmd.premium.monthly"
    static let annual  = "com.ahammock.macmd.premium.annual"

    static var all: [String] { [monthly, annual] }
}

/// Manages premium subscription state using StoreKit 2.
///
/// Responsibilities:
/// - Loads Product objects from the App Store / StoreKit config file
/// - Verifies current entitlements on launch
/// - Listens for transaction updates (renewals, revocations, family sharing)
/// - Exposes `isPremium` for the rest of the app to gate premium features
@Observable
@MainActor
final class SubscriptionManager {

    // MARK: - Published State

    /// Whether the user currently has an active premium subscription.
    /// This is cached in UserDefaults and re-verified asynchronously on launch.
    var isPremium: Bool = false

    /// The loaded Product objects, keyed by product ID.
    var products: [Product] = []

    /// Error message to display if loading/purchasing fails.
    var errorMessage: String? = nil

    // MARK: - Private

    // MARK: - Init

    init() {
        // Restore cached premium state so UI is correct before async verification completes.
        isPremium = UserDefaults.standard.bool(forKey: "isPremiumCached")
    }

    // MARK: - Public API

    /// Load products, verify entitlements, and start the transaction listener.
    /// Call this once at app launch via `.task {}`.
    func initialize() async {
        // Start listening for external transaction updates (renewals, revocations, Ask to Buy).
        // The Task is intentionally not stored — SubscriptionManager is a singleton that lives
        // for the entire app lifetime, so cancellation on deinit is not needed.
        Task(priority: .background) { [weak self] in
            for await verificationResult in Transaction.updates {
                guard case .verified(let transaction) = verificationResult else { continue }
                await transaction.finish()
                await self?.verifyEntitlements()
            }
        }
        await loadProducts()
        await verifyEntitlements()
    }

    /// Initiate a purchase for the given product.
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                guard case .verified(let transaction) = verificationResult else {
                    errorMessage = String(localized: "Purchase could not be verified.")
                    return
                }
                await transaction.finish()
                await verifyEntitlements()
            case .pending:
                // Ask to Buy — wait for parent approval via transaction listener.
                break
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Restore previous purchases (triggers App Store authentication if needed).
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await verifyEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private Helpers

    /// Load available products from the App Store or local StoreKit config file.
    private func loadProducts() async {
        do {
            let loaded = try await Product.products(for: PremiumProductID.all)
            // Sort: monthly first, then annual.
            products = loaded.sorted {
                $0.id == PremiumProductID.monthly && $1.id == PremiumProductID.annual
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Check Transaction.currentEntitlements to determine if user is premium.
    private func verifyEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if PremiumProductID.all.contains(transaction.productID),
               transaction.revocationDate == nil,
               !(transaction.isUpgraded) {
                entitled = true
                break
            }
        }
        isPremium = entitled
        UserDefaults.standard.set(entitled, forKey: "isPremiumCached")
    }

}
