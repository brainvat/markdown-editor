//
//  DocumentListView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData

/// The document list (second column) showing documents filtered by the selected sidebar item
struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    
    let sidebarItem: SidebarItem?
    @Binding var selectedDocument: Document?
    
    @Query private var allDocuments: [Document]
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var documentToDelete: Document?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        List(selection: $selectedDocument) {
            ForEach(searchResults) { document in
                NavigationLink(value: document) {
                    DocumentRowView(document: document)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        toggleFavorite(document)
                    } label: {
                        Label("Favorite", systemImage: document.isFavorite ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                    
                    Button {
                        duplicateDocument(document)
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        toggleArchive(document)
                    } label: {
                        Label(document.isArchived ? "Unarchive" : "Archive", 
                              systemImage: document.isArchived ? "tray.and.arrow.up" : "tray.and.arrow.down")
                    }
                    .tint(.orange)
                    
                    Button(role: .destructive) {
                        confirmDelete(document)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .contextMenu {
                    Button {
                        duplicateDocument(document)
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        toggleFavorite(document)
                    } label: {
                        Label(document.isFavorite ? "Remove from Favorites" : "Add to Favorites", 
                              systemImage: document.isFavorite ? "star.slash" : "star")
                    }
                    
                    Button {
                        toggleArchive(document)
                    } label: {
                        Label(document.isArchived ? "Unarchive" : "Archive", 
                              systemImage: document.isArchived ? "tray.and.arrow.up" : "tray.and.arrow.down")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        confirmDelete(document)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .searchable(text: $searchText, isPresented: $isSearching, prompt: "Search documents")
        .navigationTitle(navigationTitle)
        .onReceive(NotificationCenter.default.publisher(for: .showSearch)) { _ in
            isSearching = true
        }
        .confirmationDialog(
            "Delete \"\(documentToDelete?.title ?? "document")\"?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let doc = documentToDelete {
                    deleteDocument(doc)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    createNewDocument()
                } label: {
                    Label("New Document", systemImage: "square.and.pencil")
                }
            }
            
            ToolbarItem {
                Menu {
                    Picker("Sort By", selection: .constant(SortOption.modified)) {
                        Label("Date Modified", systemImage: "calendar")
                            .tag(SortOption.modified)
                        Label("Date Created", systemImage: "calendar.badge.plus")
                            .tag(SortOption.created)
                        Label("Title", systemImage: "textformat")
                            .tag(SortOption.title)
                        Label("Word Count", systemImage: "123.rectangle")
                            .tag(SortOption.wordCount)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var searchResults: [Document] {
        let documents = filteredDocuments
        
        guard !searchText.isEmpty else {
            return documents
        }
        
        return documents.filter { document in
            document.title.localizedCaseInsensitiveContains(searchText) ||
            document.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredDocuments: [Document] {
        guard let sidebarItem = sidebarItem else {
            return allDocuments.filter { !$0.isArchived }
        }
        
        switch sidebarItem {
        case .allDocuments:
            return allDocuments.filter { !$0.isArchived }
            
        case .favorites:
            return allDocuments.filter { $0.isFavorite && !$0.isArchived }
            
        case .recent:
            return Array(allDocuments
                .filter { !$0.isArchived }
                .sorted { $0.lastAccessedAt > $1.lastAccessedAt }
                .prefix(20))
            
        case .archived:
            return allDocuments.filter { $0.isArchived }
            
        case .project(let project):
            return allDocuments.filter { $0.project?.id == project.id && !$0.isArchived }
            
        case .tag(let tag):
            return allDocuments.filter { document in
                document.tags.contains { $0.id == tag.id } && !document.isArchived
            }
        }
    }
    
    private var navigationTitle: String {
        guard let sidebarItem = sidebarItem else {
            return "Documents"
        }
        
        switch sidebarItem {
        case .allDocuments:
            return "All Documents"
        case .favorites:
            return "Favorites"
        case .recent:
            return "Recent"
        case .archived:
            return "Archived"
        case .project(let project):
            return project.name
        case .tag(let tag):
            return tag.name
        }
    }
    
    // MARK: - Actions
    
    private func createNewDocument() {
        let document = Document(title: "Untitled Document")
        
        // Automatically associate with the current context
        if let sidebarItem = sidebarItem {
            switch sidebarItem {
            case .project(let project):
                document.project = project
            case .tag(let tag):
                document.tags.append(tag)
            default:
                break
            }
        }
        
        modelContext.insert(document)
        selectedDocument = document
    }
    
    private func toggleFavorite(_ document: Document) {
        document.isFavorite.toggle()
    }
    
    private func toggleArchive(_ document: Document) {
        document.isArchived.toggle()
    }
    
    private func duplicateDocument(_ document: Document) {
        let duplicate = Document(
            title: "\(document.title) (Copy)",
            content: document.content,
            tags: document.tags,
            project: document.project
        )
        modelContext.insert(duplicate)
    }
    
    private func confirmDelete(_ document: Document) {
        documentToDelete = document
        showDeleteConfirmation = true
    }
    
    private func deleteDocument(_ document: Document) {
        modelContext.delete(document)
        if selectedDocument?.id == document.id {
            selectedDocument = nil
        }
    }
}

/// Row view for displaying a document in the list
struct DocumentRowView: View {
    let document: Document
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(document.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if document.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            
            HStack {
                RelativeTimestampViewSimple(date: document.modifiedAt)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text("\(document.wordCount) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !document.content.isEmpty {
                Text(document.content)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sort Option

enum SortOption {
    case modified
    case created
    case title
    case wordCount
}

// MARK: - Relative Timestamp View

/// Simple relative timestamp view that updates every minute
struct RelativeTimestampViewSimple: View {
    let date: Date
    @State private var displayText = ""
    
    var body: some View {
        Text(displayText)
            .font(.caption)
            .foregroundStyle(.secondary)
            .onAppear {
                updateDisplayText()
            }
            .task {
                // Update every minute instead of constantly
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(60))
                    updateDisplayText()
                }
            }
    }
    
    private func updateDisplayText() {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        displayText = formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationSplitView {
        Text("Sidebar")
    } content: {
        DocumentListView(
            sidebarItem: .allDocuments,
            selectedDocument: .constant(nil)
        )
        .modelContainer(for: Document.self, inMemory: true)
    } detail: {
        Text("Detail")
    }
}
