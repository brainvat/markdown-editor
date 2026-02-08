//
//  AppCommands.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI

/// App-wide keyboard shortcuts and menu commands
struct AppCommands: Commands {
    var body: some Commands {
        // File menu enhancements
        CommandGroup(after: .newItem) {
            Divider()
            
            Button("Export as PDF...") {
                // Trigger export action
                NotificationCenter.default.post(name: .exportToPDF, object: nil)
            }
            .keyboardShortcut("e", modifiers: .command)
            
            Button("Export as HTML...") {
                // Trigger export action
                NotificationCenter.default.post(name: .exportToHTML, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }
        
        // Navigate menu
        CommandMenu("Navigate") {
            Button("All Documents") {
                NotificationCenter.default.post(name: .navigateToAllDocuments, object: nil)
            }
            .keyboardShortcut("1", modifiers: .command)
            
            Button("Favorites") {
                NotificationCenter.default.post(name: .navigateToFavorites, object: nil)
            }
            .keyboardShortcut("2", modifiers: .command)
            
            Button("Recent") {
                NotificationCenter.default.post(name: .navigateToRecent, object: nil)
            }
            .keyboardShortcut("3", modifiers: .command)
            
            Divider()
            
            Button("Toggle Favorite") {
                NotificationCenter.default.post(name: .toggleFavorite, object: nil)
            }
            .keyboardShortcut("d", modifiers: .command)
        }
        
        // View menu enhancements
        CommandGroup(after: .sidebar) {
            Button("Toggle Preview") {
                NotificationCenter.default.post(name: .togglePreview, object: nil)
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Preview on Right") {
                NotificationCenter.default.post(name: .previewPositionTrailing, object: nil)
            }
            
            Button("Preview on Left") {
                NotificationCenter.default.post(name: .previewPositionLeading, object: nil)
            }
            
            Button("Preview Below") {
                NotificationCenter.default.post(name: .previewPositionBottom, object: nil)
            }
        }
        
        // Search
        CommandGroup(after: .toolbar) {
            Button("Find in Documents...") {
                NotificationCenter.default.post(name: .showSearch, object: nil)
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    // Export
    static let exportToPDF = Notification.Name("exportToPDF")
    static let exportToHTML = Notification.Name("exportToHTML")
    
    // Navigation
    static let navigateToAllDocuments = Notification.Name("navigateToAllDocuments")
    static let navigateToFavorites = Notification.Name("navigateToFavorites")
    static let navigateToRecent = Notification.Name("navigateToRecent")
    static let toggleFavorite = Notification.Name("toggleFavorite")
    
    // View
    static let togglePreview = Notification.Name("togglePreview")
    static let previewPositionTrailing = Notification.Name("previewPositionTrailing")
    static let previewPositionLeading = Notification.Name("previewPositionLeading")
    static let previewPositionBottom = Notification.Name("previewPositionBottom")
    
    // Search
    static let showSearch = Notification.Name("showSearch")
}
