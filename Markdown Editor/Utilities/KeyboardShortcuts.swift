//
//  KeyboardShortcuts.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI

/// View modifier for adding app-wide keyboard shortcuts
struct KeyboardShortcutsModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDocument: Document?
    @Binding var selectedSidebarItem: SidebarItem?
    
    let onNewDocument: () -> Void
    let onExport: () -> Void
    
    func body(content: Content) -> some View {
        content
            // File operations
            .keyboardShortcut("n", modifiers: .command) {
                onNewDocument()
            }
            .keyboardShortcut("e", modifiers: .command) {
                onExport()
            }
            .keyboardShortcut("w", modifiers: .command) {
                // Close/archive document
                if let document = selectedDocument {
                    document.isArchived = true
                    selectedDocument = nil
                }
            }
            // Navigation
            .keyboardShortcut("1", modifiers: [.command, .shift]) {
                selectedSidebarItem = .allDocuments
            }
            .keyboardShortcut("2", modifiers: [.command, .shift]) {
                selectedSidebarItem = .favorites
            }
            .keyboardShortcut("3", modifiers: [.command, .shift]) {
                selectedSidebarItem = .recent
            }
            // Document operations
            .keyboardShortcut("f", modifiers: .command) {
                // Toggle favorite
                if let document = selectedDocument {
                    document.isFavorite.toggle()
                }
            }
    }
}

extension View {
    /// Adds keyboard shortcuts to the view
    func withKeyboardShortcuts(
        selectedDocument: Binding<Document?>,
        selectedSidebarItem: Binding<SidebarItem?>,
        onNewDocument: @escaping () -> Void,
        onExport: @escaping () -> Void
    ) -> some View {
        self.modifier(KeyboardShortcutsModifier(
            selectedDocument: selectedDocument,
            selectedSidebarItem: selectedSidebarItem,
            onNewDocument: onNewDocument,
            onExport: onExport
        ))
    }
}
