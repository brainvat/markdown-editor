//
//  ContentView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData

/// Main three-column layout for Mac MD
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @AppStorage("hasCreatedSampleDocument") private var hasCreatedSampleDocument = false
    
    @State private var selectedSidebarItem: SidebarItem? = .allDocuments
    @State private var selectedDocument: Document?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showWelcomeSplash = false
    
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
        .onReceive(NotificationCenter.default.publisher(for: .navigateToAllDocuments)) { _ in
            selectedSidebarItem = .allDocuments
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToFavorites)) { _ in
            selectedSidebarItem = .favorites
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToRecent)) { _ in
            selectedSidebarItem = .recent
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleFavorite)) { _ in
            if let document = selectedDocument {
                document.isFavorite.toggle()
            }
        }
        .sheet(isPresented: $showWelcomeSplash) {
            WelcomeSplashView()
        }
        .onAppear {
            checkFirstLaunch()
        }
    }
    
    // MARK: - First Launch Handling
    
    /// Check if this is the first launch and show splash screen + create sample document
    private func checkFirstLaunch() {
        // Always show splash unless user has checked "Don't show this again"
        if !hasLaunchedBefore {
            showWelcomeSplash = true
        }
        
        // Only create sample document once
        if !hasCreatedSampleDocument {
            createSampleDocument()
            hasCreatedSampleDocument = true
        }
    }
    
    /// Create a sample document to demonstrate features on first launch
    private func createSampleDocument() {
        // Create "Getting Started" project
        let gettingStartedProject = Project(
            name: "Getting Started",
            projectDescription: "Sample project to help you learn Mac MD",
            colorHex: "#007AFF",
            iconName: "book.closed"
        )
        modelContext.insert(gettingStartedProject)
        
        // Create "Welcome" tag
        let welcomeTag = Tag(name: "Welcome", colorHex: "#34C759")
        modelContext.insert(welcomeTag)
        
        // Create sample document with comprehensive Markdown examples
        let sampleContent = """
        # Welcome to Mac MD! 👋
        
        Mac MD is a modern, feature-rich Markdown editor for macOS, iOS, and iPadOS. This sample document will help you get started.
        
        ## The Three-Column Layout
        
        Mac MD uses a three-column layout for efficient workflow:
        
        1. **Sidebar** (left): Browse Projects, view Favorites, and access Recent documents
        2. **Document List** (center): See all your documents with sorting and filtering
        3. **Editor & Preview** (right): Write Markdown and see live preview side-by-side
        
        ## Markdown Basics
        
        ### Text Formatting
        
        You can make text **bold** or *italic*, or even ***bold and italic***. You can also use ~~strikethrough~~ text.
        
        ### Links and Code
        
        Create [links](https://www.example.com) easily. Inline `code` looks like this.
        
        ### Lists
        
        **Unordered lists:**
        - First item
        - Second item
          - Nested item
          - Another nested item
        - Third item
        
        **Ordered lists:**
        1. First step
        2. Second step
        3. Third step
        
        **Task lists:**
        - [x] Learn about Mac MD
        - [ ] Create your first document
        - [ ] Organize with projects and tags
        - [ ] Export to PDF
        
        ### Code Blocks
        
        ```swift
        // Mac MD supports syntax highlighting!
        func greet(name: String) {
            print("Hello, \\(name)!")
        }
        
        greet(name: "World")
        ```
        
        ### Quotes
        
        > "The best way to predict the future is to create it."
        > — Abraham Lincoln
        
        ### Tables
        
        | Feature | Mac | iPad | iPhone |
        |---------|-----|------|--------|
        | Live Preview | ✓ | ✓ | ✓ |
        | PDF Export | ✓ | ✓ | ✓ |
        | HTML Export | ✓ | ✗ | ✗ |
        | CloudKit Sync | ✓ | ✓ | ✓ |
        
        ## Organizing Your Documents
        
        ### Projects
        
        Projects are like folders. This document is in the "Getting Started" project. Create new projects from the sidebar by clicking the + button next to "Projects".
        
        ### Tags
        
        Tags help you categorize documents across projects. A document can have multiple tags. This document has the "Welcome" tag. Add tags from the document list context menu.
        
        ### Favorites
        
        Star important documents to quickly access them from the Favorites section in the sidebar.
        
        ## Exporting
        
        Mac MD supports multiple export formats:
        
        - **PDF** (Mac, iPad, iPhone): Native PDF generation with styling
        - **HTML** (Mac only): Standalone HTML files with embedded CSS
        - **Markdown** (Mac only): Export as .md files
        
        Use the keyboard shortcuts:
        - ⌘E: Export to PDF
        - ⌘⇧E: Export to HTML (Mac only)
        
        ## Keyboard Shortcuts
        
        - **⌘N**: New document
        - **⌘E**: Export to PDF
        - **⌘⇧E**: Export to HTML (Mac)
        - **⌘D**: Toggle favorite
        - **⌘1**: All Documents
        - **⌘2**: Favorites
        - **⌘3**: Recent
        - **⌘⇧P**: Toggle preview
        - **⌘⇧F**: Search documents
        
        ## What's Next?
        
        1. Try editing this document and watch the preview update in real-time
        2. Create your own documents with the + button
        3. Organize them into projects
        4. Apply tags for easy filtering
        5. Export your work to PDF or HTML
        
        ## Need Help?
        
        Visit our [GitHub repository](https://github.com/brainvat/markdown-editor) for:
        - Documentation
        - Feature requests
        - Bug reports
        - Community support
        
        ---
        
        **Enjoy writing in Markdown!** 📝
        """
        
        let sampleDocument = Document(
            title: "Welcome to Mac MD",
            content: sampleContent,
            tags: [welcomeTag],
            project: gettingStartedProject
        )
        sampleDocument.isFavorite = true
        modelContext.insert(sampleDocument)
        
        // Save the context
        try? modelContext.save()
    }
}

#Preview("With Documents") {
    let container = try! ModelContainer(
        for: Document.self, Project.self, Tag.self,
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
        title: "Welcome to Mac MD",
        content: """
        # Welcome to Mac MD
        
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
            for: [Document.self, Project.self, Tag.self],
            inMemory: true
        )
}
