//
//  PremiumFeature.swift
//  Markdown Editor
//
//  Centralizes which features require a premium subscription.
//  Add new cases here as premium features are introduced.
//

import Foundation

/// Represents a feature that requires a premium subscription.
/// Use this enum as the single source of truth for premium feature metadata.
enum PremiumFeature: String, CaseIterable, Identifiable {
    case iCloudSync

    var id: String { rawValue }

    /// Human-readable feature name shown in the paywall.
    var title: String {
        switch self {
        case .iCloudSync: return String(localized: "iCloud Sync")
        }
    }

    /// Short description shown in the paywall feature list.
    var description: String {
        switch self {
        case .iCloudSync: return String(localized: "Keep your documents in sync across all your Apple devices automatically.")
        }
    }

    /// SF Symbol name used in the paywall feature list.
    var systemImage: String {
        switch self {
        case .iCloudSync: return "icloud"
        }
    }
}
