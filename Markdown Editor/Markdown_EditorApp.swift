//
//  Markdown_EditorApp.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData

@main
struct Markdown_EditorApp: App {

    // MARK: - Subscription

    /// Shared subscription manager — initialized before the ModelContainer so
    /// CloudKit enablement can be determined at launch.
    @State private var subscriptionManager = SubscriptionManager()

    // MARK: - Data Container

    /// Build the SwiftData container. CloudKit is enabled only when the user
    /// has an active premium subscription (cached state from previous launch).
    /// Changing subscription status requires a restart to take effect.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Document.self,
            Tag.self,
            Project.self,
            Snippet.self
        ])

        // Use cached premium state to decide CloudKit at launch.
        // The SubscriptionManager will re-verify asynchronously after launch.
        let isPremiumCached = UserDefaults.standard.bool(forKey: "isPremiumCached")
        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase = isPremiumCached ? .automatic : .none

        let modelConfiguration = ModelConfiguration(
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKitDatabase
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .task {
                    // Verify entitlements asynchronously on launch.
                    await subscriptionManager.initialize()
                }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            AppCommands()
        }

        #if os(macOS)
        Settings {
            SettingsView()
                .environment(subscriptionManager)
        }
        #endif
    }
}
