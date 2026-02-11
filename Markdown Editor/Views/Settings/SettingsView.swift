//
//  SettingsView.swift
//  Markdown Editor
//
//  Created by Claude on 2/10/26.
//

import SwiftUI

/// The app Settings/Preferences screen.
/// On macOS, this is presented as a native Settings scene (⌘,).
/// On iOS/iPadOS, it is presented as a sheet from the toolbar.
struct SettingsView: View {
    
    // MARK: - Preferences

    @AppStorage("editorFontSize")      private var editorFontSize: Double = 14
    @AppStorage("editorFontFamily")    private var editorFontFamily: String = "monospaced"
    @AppStorage("previewFontSize")     private var previewFontSize: Double = 16
    @AppStorage("selectedColorTheme")  private var selectedColorTheme: String = "Basic"
    @AppStorage("iCloudSyncEnabled")   private var iCloudSyncEnabled: Bool = false

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    // MARK: - Sheet State

    @State private var showPaywall = false
    
    // MARK: - Body
    
    var body: some View {
        #if os(macOS)
        macOSSettings
        #else
        NavigationStack {
            iOSSettings
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        #endif
    }
    
    // MARK: - macOS Layout
    
    #if os(macOS)
    private var macOSSettings: some View {
        TabView {
            editorSection
                .tabItem {
                    Label("Editor", systemImage: "pencil")
                }

            previewSection
                .tabItem {
                    Label("Preview", systemImage: "eye")
                }

            themeSection
                .tabItem {
                    Label("Themes", systemImage: "paintpalette")
                }

            syncSection
                .tabItem {
                    Label("Sync", systemImage: "icloud")
                }

            aboutSection
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 480)
        .padding()
        .sheet(isPresented: $showPaywall) {
            PremiumPaywallView(trigger: .iCloudSync)
                .environment(subscriptionManager)
        }
    }
    #endif
    
    // MARK: - iOS Layout
    
    private var iOSSettings: some View {
        Form {
            Section("Editor") { editorControls }
            Section("Preview") { previewControls }
            Section("Color Theme") { themeControls }
            Section("Sync") { syncControls }
            Section("About") { aboutControls }
        }
        .sheet(isPresented: $showPaywall) {
            PremiumPaywallView(trigger: .iCloudSync)
                .environment(subscriptionManager)
        }
    }
    
    // MARK: - Editor Section
    
    private var editorSection: some View {
        Form {
            Section("Editor") { editorControls }
        }
        .formStyle(.grouped)
        .frame(minHeight: 160)
    }
    
    private var editorControls: some View {
        Group {
            Picker("Font Family", selection: $editorFontFamily) {
                Text("Monospaced").tag("monospaced")
                Text("System (Sans-serif)").tag("default")
                Text("Serif").tag("serif")
                Text("Rounded").tag("rounded")
            }
            
            HStack {
                Text("Font Size")
                Spacer()
                Stepper(
                    value: $editorFontSize,
                    in: 8...36,
                    step: 1
                ) {
                    Text("\(Int(editorFontSize)) pt")
                        .monospacedDigit()
                        .frame(minWidth: 44, alignment: .trailing)
                }
            }
            
            // Live preview of editor font
            Text("The quick brown fox jumps over the lazy dog.")
                .font(.system(size: editorFontSize, design: fontDesign(for: editorFontFamily)))
                .foregroundStyle(currentTheme.foreground)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(currentTheme.background)
                .clipShape(.rect(cornerRadius: 6))
        }
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        Form {
            Section("Preview") { previewControls }
        }
        .formStyle(.grouped)
        .frame(minHeight: 120)
    }
    
    private var previewControls: some View {
        HStack {
            Text("Font Size")
            Spacer()
            Stepper(
                value: $previewFontSize,
                in: 10...32,
                step: 1
            ) {
                Text("\(Int(previewFontSize)) pt")
                    .monospacedDigit()
                    .frame(minWidth: 44, alignment: .trailing)
            }
        }
    }
    
    // MARK: - Theme Section
    
    private var themeSection: some View {
        Form {
            Section("Color Theme") { themeControls }
        }
        .formStyle(.grouped)
        .frame(minHeight: 200)
    }
    
    private var themeControls: some View {
        ThemePickerView(selectedThemeName: $selectedColorTheme)
    }
    
    // MARK: - Sync Section

    private var syncSection: some View {
        Form {
            Section("Sync") { syncControls }
        }
        .formStyle(.grouped)
        .frame(minHeight: 120)
    }

    private var syncControls: some View {
        Group {
            if subscriptionManager.isPremium {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud Sync", systemImage: "icloud")
                }
                if iCloudSyncEnabled {
                    Text("Restart Mac MD to apply sync changes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Label("iCloud Sync", systemImage: "icloud")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("Premium")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())
                    }
                }
                .buttonStyle(.plain)

                Text("Subscribe to Mac MD Premium to sync your documents across all your Apple devices.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Form {
            Section("About") { aboutControls }
        }
        .formStyle(.grouped)
        .frame(minHeight: 160)
    }
    
    private var aboutControls: some View {
        Group {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Build")
                Spacer()
                Text(appBuild)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Developer")
                Spacer()
                Text("ahammock")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currentTheme: ColorTheme {
        ColorTheme.preset(named: selectedColorTheme)
    }
    
    private func fontDesign(for family: String) -> Font.Design {
        switch family {
        case "default":    return .default
        case "serif":      return .serif
        case "rounded":    return .rounded
        default:           return .monospaced
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

// MARK: - Preview

#Preview("macOS") {
    SettingsView()
        .frame(width: 500, height: 400)
}

#Preview("iOS") {
    SettingsView()
}
