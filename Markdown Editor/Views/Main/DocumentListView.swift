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
    @Query private var allProjects: [Project]
    @Query private var allTags: [Tag]
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var documentToDelete: Document?
    @State private var showDeleteConfirmation = false
    @State private var projectSheetItem: ProjectSheetItem?
    @State private var documentForNewProject: Document?
    @State private var sortOption: SortOption = .modified
    
    var body: some View {
        List(selection: $selectedDocument) {
            ForEach(searchResults) { document in
                DocumentListItemView(
                    document: document,
                    allProjects: allProjects,
                    allTags: allTags,
                    onFavorite: { toggleFavorite(document) },
                    onDuplicate: { duplicateDocument(document) },
                    onArchive: { toggleArchive(document) },
                    onDelete: { confirmDelete(document) },
                    onMoveToProject: { project in moveDocumentToProject(document, project: project) },
                    onCreateProjectAndMove: { createProjectAndMove(document) },
                    onApplyTag: { tag in applyTagToDocument(document, tag: tag) },
                    onRemoveTag: { tag in removeTagFromDocument(document, tag: tag) }
                )
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
        .sheet(item: $projectSheetItem) { sheetItem in
            ProjectEditSheet(project: sheetItem.project)
                .onDisappear {
                    // If we were creating a new project for a document, assign it
                    if let document = documentForNewProject,
                       let newProject = sheetItem.project,
                       allProjects.contains(where: { $0.id == newProject.id }) {
                        document.project = newProject
                    }
                    documentForNewProject = nil
                }
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
                    Picker("Sort By", selection: $sortOption) {
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
        var documents = filteredDocuments
        
        // Apply search filter
        if !searchText.isEmpty {
            documents = documents.filter { document in
                document.title.localizedCaseInsensitiveContains(searchText) ||
                document.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        return sortedDocuments(documents)
    }
    
    private func sortedDocuments(_ documents: [Document]) -> [Document] {
        switch sortOption {
        case .modified:
            return documents.sorted { $0.modifiedAt > $1.modifiedAt }
        case .created:
            return documents.sorted { $0.createdAt > $1.createdAt }
        case .title:
            return documents.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .wordCount:
            return documents.sorted { $0.wordCount > $1.wordCount }
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
    
    private func moveDocumentToProject(_ document: Document, project: Project?) {
        document.project = project
    }
    
    private func createProjectAndMove(_ document: Document) {
        // Create a new project
        let newProject = Project(name: "New Project")
        modelContext.insert(newProject)
        
        // Store the document to assign after sheet dismissal
        documentForNewProject = document
        
        // Open the edit sheet for the new project
        projectSheetItem = ProjectSheetItem(project: newProject)
    }
    
    private func applyTagToDocument(_ document: Document, tag: Tag) {
        if !document.tags.contains(where: { $0.id == tag.id }) {
            document.tags.append(tag)
        }
    }
    
    private func removeTagFromDocument(_ document: Document, tag: Tag) {
        document.tags.removeAll(where: { $0.id == tag.id })
    }
}

// MARK: - Document List Item View

struct DocumentListItemView: View {
    let document: Document
    let allProjects: [Project]
    let allTags: [Tag]
    let onFavorite: () -> Void
    let onDuplicate: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void
    let onMoveToProject: (Project?) -> Void
    let onCreateProjectAndMove: () -> Void
    let onApplyTag: (Tag) -> Void
    let onRemoveTag: (Tag) -> Void
    
    var body: some View {
        NavigationLink(value: document) {
            DocumentRowView(document: document)
        }
        .draggable(document.id.uuidString)
        .swipeActions(edge: .leading) {
            Button(action: onFavorite) {
                Label("Favorite", systemImage: document.isFavorite ? "star.fill" : "star")
            }
            .tint(.yellow)
            
            Button(action: onDuplicate) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            Button(action: onArchive) {
                Label(document.isArchived ? "Unarchive" : "Archive", 
                      systemImage: document.isArchived ? "tray.and.arrow.up" : "tray.and.arrow.down")
            }
            .tint(.orange)
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            contextMenuContent
        }
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button(action: onDuplicate) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        Button(action: onFavorite) {
            Label(document.isFavorite ? "Remove from Favorites" : "Add to Favorites", 
                  systemImage: document.isFavorite ? "star.slash" : "star")
        }
        
        Button(action: onArchive) {
            Label(document.isArchived ? "Unarchive" : "Archive", 
                  systemImage: document.isArchived ? "tray.and.arrow.up" : "tray.and.arrow.down")
        }
        
        Divider()
        
        Menu {
            Button {
                onMoveToProject(nil)
            } label: {
                Label("None", systemImage: "folder.badge.minus")
            }
            
            Divider()
            
            Button {
                onCreateProjectAndMove()
            } label: {
                Label("New Project...", systemImage: "folder.badge.plus")
            }
            
            Divider()
            
            ForEach(allProjects) { project in
                Button {
                    onMoveToProject(project)
                } label: {
                    Label {
                        Text(project.name)
                    } icon: {
                        Image(systemName: project.iconName)
                    }
                }
            }
        } label: {
            Label("Move to Project", systemImage: "folder")
        }
        
        Menu {
            ForEach(allTags) { tag in
                let isApplied = document.tags.contains(where: { $0.id == tag.id })
                
                Button {
                    if isApplied {
                        onRemoveTag(tag)
                    } else {
                        onApplyTag(tag)
                    }
                } label: {
                    Label {
                        Text(tag.name)
                    } icon: {
                        if isApplied {
                            Image(systemName: "checkmark")
                        } else {
                            Circle()
                                .fill(Color(hex: tag.colorHex))
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
        } label: {
            Label("Apply Tags", systemImage: "tag")
        }
        
        Divider()
        
        Button(role: .destructive, action: onDelete) {
            Label("Delete", systemImage: "trash")
        }
    }
}

// MARK: - Document Row View

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
                
                // Tag badges
                if !document.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(document.tags.prefix(3)) { tag in
                            Circle()
                                .fill(Color(hex: tag.colorHex))
                                .frame(width: 8, height: 8)
                        }
                        
                        if document.tags.count > 3 {
                            Text("+\(document.tags.count - 3)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
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


