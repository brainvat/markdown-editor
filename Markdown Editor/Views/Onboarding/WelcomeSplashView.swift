//
//  WelcomeSplashView.swift
//  Markdown Editor
//
//  Created by Claude on 2026-02-08.
//

import SwiftUI

/// Welcome splash screen shown on first launch to introduce new users to Mac MD
struct WelcomeSplashView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @State private var dontShowAgain = false
    
    var body: some View {
        #if os(macOS)
        ScrollView {
            VStack(spacing: 0) {
                // Header section with app branding
                headerSection
                
                // Main content explaining the app
                contentSection
                
                // Footer with action buttons
                footerSection
            }
            .frame(width: 600)
        }
        .frame(width: 600, height: 650)
        .background(backgroundGradient)
        #else
        VStack(spacing: 0) {
            // Header section with app branding
            headerSection
            
            // Main content explaining the app
            contentSection
            
            // Footer with action buttons
            footerSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        #endif
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // App icon placeholder (will be replaced with actual icon)
            iconPlaceholder
            
            // App name and tagline
            Text("Mac MD")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            
            Text("Modern Markdown Editing")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
        .padding(.bottom, 24)
    }
    
    private var iconPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Text("MD")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome to Mac MD")
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            
            featureRow(
                icon: "sidebar.left",
                title: "Three-Column Layout",
                description: "Projects, Documents, and Editor side-by-side for efficient workflow"
            )
            
            featureRow(
                icon: "doc.text",
                title: "Live Preview",
                description: "See your Markdown rendered in real-time as you type"
            )
            
            if subscriptionManager.isPremium {
                featureRow(
                    icon: "icloud",
                    title: "iCloud Sync",
                    description: "Your documents automatically sync across Mac, iPad, and iPhone"
                )
            }

            featureRow(
                icon: "tag",
                title: "Projects & Tags",
                description: "Organize documents with projects and apply multiple tags"
            )
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity)
    }
    
    private func featureRow(icon: String, title: LocalizedStringKey, description: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            // Don't show again toggle
            Toggle("Don't show this again", isOn: $dontShowAgain)
                #if os(macOS)
                .toggleStyle(.checkbox)
                #else
                .toggleStyle(.switch)
                #endif
                .padding(.horizontal, 40)
            
            // Get Started button
            Button(action: getStarted) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        #if os(macOS)
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .windowBackgroundColor).opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        #else
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color(uiColor: .systemBackground).opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        #endif
    }
    
    // MARK: - Actions
    
    private func getStarted() {
        if dontShowAgain {
            hasLaunchedBefore = true
        }
        dismiss()
    }
}

// MARK: - Previews

#Preview("Welcome Splash - Light") {
    WelcomeSplashView()
        .preferredColorScheme(.light)
        .environment(SubscriptionManager())
}

#Preview("Welcome Splash - Dark") {
    WelcomeSplashView()
        .preferredColorScheme(.dark)
        .environment(SubscriptionManager())
}

#if os(iOS)
#Preview("Welcome Splash - iOS") {
    WelcomeSplashView()
        .environment(SubscriptionManager())
}
#endif
