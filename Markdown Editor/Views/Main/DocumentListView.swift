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
    
    var body: some View {
        List(selection: $selectedDocument) {
            ForEach(filteredDocuments) { document in
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
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteDocument(document)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
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
            
        case .project(let project):
            return allDocuments.filter { $0.project?.id == project.id && !$0.isArchived }
            
        case .group(let group):
            return allDocuments.filter { $0.group?.id == group.id && !$0.isArchived }
            
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
        case .project(let project):
            return project.name
        case .group(let group):
            return group.name
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
            case .group(let group):
                document.group = group
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
    
    private func deleteDocument(_ document: Document) {
        modelContext.delete(document)
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
                Text(document.modifiedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
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
