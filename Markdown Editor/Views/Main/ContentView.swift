//
//  ContentView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData

/// Main three-column layout for MacDown Pro
struct ContentView: View {
    @State private var selectedSidebarItem: SidebarItem? = .allDocuments
    @State private var selectedDocument: Document?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // First column: Sidebar (source list)
            SidebarView(selectedSidebarItem: $selectedSidebarItem)
        } content: {
            // Second column: Document list
            DocumentListView(
                sidebarItem: selectedSidebarItem,
                selectedDocument: $selectedDocument
            )
        } detail: {
            // Third column: Editor with preview
            if let document = selectedDocument {
                EditorView(document: document)
            } else {
                ContentUnavailableView(
                    "No Document Selected",
                    systemImage: "doc.text",
                    description: Text("Select a document from the list or create a new one to get started.")
                )
            }
        }
    }
}

#Preview("With Documents") {
    let container = try! ModelContainer(
        for: Document.self, Project.self, Group.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // Create sample data
    let context = container.mainContext
    
    let project = Project(name: "Blog Posts", iconName: "text.book.closed")
    context.insert(project)
    
    let tag1 = Tag(name: "Work", colorHex: "#007AFF")
    let tag2 = Tag(name: "Personal", colorHex: "#FF3B30")
    context.insert(tag1)
    context.insert(tag2)
    
    let doc1 = Document(
        title: "Welcome to MacDown Pro",
        content: """
        # Welcome to MacDown Pro
        
        This is a **modern** Markdown editor for macOS, iOS, and iPadOS.
        
        ## Features
        
        - Live preview
        - Syntax highlighting
        - Export to PDF and HTML
        - CloudKit syncing
        
        ### Getting Started
        
        Start typing in the editor and see your changes in real-time!
        """,
        tags: [tag1],
        project: project
    )
    
    let doc2 = Document(
        title: "Meeting Notes",
        content: """
        # Meeting Notes - Feb 7, 2026
        
        ## Attendees
        - Alice
        - Bob
        - Charlie
        
        ## Action Items
        - [ ] Review Q1 goals
        - [ ] Schedule follow-up
        - [x] Send agenda
        """,
        tags: [tag2]
    )
    
    context.insert(doc1)
    context.insert(doc2)
    
    return ContentView()
        .modelContainer(container)
}

#Preview("Empty State") {
    ContentView()
        .modelContainer(
            for: [Document.self, Project.self, Group.self, Tag.self],
            inMemory: true
        )
}
