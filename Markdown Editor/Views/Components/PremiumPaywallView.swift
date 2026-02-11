//
//  PremiumPaywallView.swift
//  Markdown Editor
//
//  Paywall sheet for Mac MD Premium subscriptions.
//  Uses StoreKit's native SubscriptionStoreView for purchase/restore UI.
//

import StoreKit
import SwiftUI

/// Paywall sheet presented when a user tries to access a premium feature.
/// Pass the `trigger` feature so the paywall can highlight why it was shown.
struct PremiumPaywallView: View {

    let trigger: PremiumFeature

    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var body: some View {
        SubscriptionStoreView(productIDs: PremiumProductID.all) {
            marketingHeader
        }
        .backgroundStyle(.clear)
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .onInAppPurchaseCompletion { _, result in
            if case .success = result {
                dismiss()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .buttonStyle(.plain)
        }
        .task {
            // Dismiss automatically if the user is already premium
            // (e.g. they restored on a different device).
            if subscriptionManager.isPremium {
                dismiss()
            }
        }
    }

    // MARK: - Marketing Header

    private var marketingHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 52))
                .foregroundStyle(.yellow)
                .padding(.top, 8)

            Text("Mac MD Premium")
                .font(.title.bold())

            Text("Unlock powerful features that keep your writing in sync across all your Apple devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Feature list — highlight the trigger feature
            VStack(alignment: .leading, spacing: 10) {
                ForEach(PremiumFeature.allCases) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.systemImage)
                            .frame(width: 28)
                            .foregroundStyle(feature == trigger ? .yellow : .secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(.subheadline.weight(feature == trigger ? .semibold : .regular))
                            Text(feature.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    PremiumPaywallView(trigger: .iCloudSync)
        .environment(SubscriptionManager())
}
