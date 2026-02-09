//
//  SidebarView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData

/// The source list (first column) showing projects, groups, and tags
struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Query private var tags: [Tag]
    @Query private var allDocuments: [Document]
    
    @Binding var selectedSidebarItem: SidebarItem?
    
    @State private var projectSheetItem: ProjectSheetItem?
    @State private var projectToDelete: Project?
    @State private var showDeleteProjectConfirmation = false
    
    var body: some View {
        listContent
            .navigationTitle("Mac MD")
            .toolbar {
                addButton
            }
            .sheet(item: $projectSheetItem) { sheetItem in
                ProjectEditSheet(project: sheetItem.project)
            }
            .confirmationDialog(
                "Delete Project",
                isPresented: $showDeleteProjectConfirmation,
                presenting: projectToDelete
            ) { project in
                Button("Delete Project Only", role: .destructive) {
                    deleteProject()
                }
                Button("Cancel", role: .cancel) {}
            } message: { project in
                Text("Delete '\(project.name)'? Documents in this project will not be deleted.")
            }
    }
    
    private var listContent: some View {
        List(selection: $selectedSidebarItem) {
            smartCollectionsSection
            projectsSection
            tagsSection
        }
    }
    
    private var smartCollectionsSection: some View {
        Section {
            NavigationLink(value: SidebarItem.allDocuments) {
                Label("All Documents", systemImage: "doc.text")
            }
            
            NavigationLink(value: SidebarItem.favorites) {
                Label("Favorites", systemImage: "star")
            }
            
            NavigationLink(value: SidebarItem.recent) {
                Label("Recent", systemImage: "clock")
            }
            
            NavigationLink(value: SidebarItem.archived) {
                Label("Archived", systemImage: "archivebox")
            }
        } header: {
            HStack {
                Text("Documents")
                Spacer()
                Button(action: quickAddDocument) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var projectsSection: some View {
        Section {
            ForEach(projects) { project in
                ProjectRowView(
                    project: project,
                    onEdit: { editProject(project) },
                    onDelete: { confirmDeleteProject(project) },
                    onDocumentsDrop: { docs in moveDocumentsToProject(docs, to: project) }
                )
            }
        } header: {
            HStack {
                Text("Projects")
                Spacer()
                Button(action: quickAddProject) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var tagsSection: some View {
        Section {
            ForEach(tags) { tag in
                NavigationLink(value: SidebarItem.tag(tag)) {
                    Label {
                        Text(tag.name)
                    } icon: {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(Color(hex: tag.colorHex))
                    }
                }
            }
        } header: {
            HStack {
                Text("Tags")
                Spacer()
                Button(action: quickAddTag) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var addButton: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .navigation) {
            Menu {
                Button {
                    createNewDocument()
                } label: {
                    Label("New Document", systemImage: "doc.badge.plus")
                }
                
                Button {
                    createNewProject()
                } label: {
                    Label("New Project", systemImage: "folder.badge.plus")
                }
                
                Button {
                    createNewTag()
                } label: {
                    Label("New Tag", systemImage: "tag")
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    createNewDocument()
                } label: {
                    Label("New Document", systemImage: "doc.badge.plus")
                }
                
                Button {
                    createNewProject()
                } label: {
                    Label("New Project", systemImage: "folder.badge.plus")
                }
                
                Button {
                    createNewTag()
                } label: {
                    Label("New Tag", systemImage: "tag")
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
        #endif
    }
    
    // MARK: - Actions
    
    private func createNewDocument() {
        let document = Document(title: "Untitled Document")
        modelContext.insert(document)
    }
    
    private func createNewProject() {
        projectSheetItem = ProjectSheetItem(project: nil)
    }
    
    private func createNewTag() {
        let tag = Tag(name: "New Tag")
        modelContext.insert(tag)
    }
    
    // MARK: - Quick Add (inline creation without sheets)
    
    private func quickAddDocument() {
        let document = Document(title: "Untitled Document")
        modelContext.insert(document)
    }
    
    private func quickAddProject() {
        let project = Project(name: "New Project")
        modelContext.insert(project)
    }
    
    private func quickAddTag() {
        let tag = Tag(name: "New Tag")
        modelContext.insert(tag)
    }
    
    // MARK: - Project CRUD
    
    private func editProject(_ project: Project) {
        projectSheetItem = ProjectSheetItem(project: project)
    }
    
    private func confirmDeleteProject(_ project: Project) {
        projectToDelete = project
        showDeleteProjectConfirmation = true
    }
    
    private func deleteProject() {
        guard let project = projectToDelete else { return }
        modelContext.delete(project)
        projectToDelete = nil
    }
    
    private func moveDocumentsToProject(_ documentIDs: [String], to project: Project) {
        for idString in documentIDs {
            guard let uuid = UUID(uuidString: idString),
                  let document = allDocuments.first(where: { $0.id == uuid }) else {
                continue
            }
            document.project = project
        }
    }
}

// MARK: - Sidebar Item

/// Represents the different types of items that can be selected in the sidebar
enum SidebarItem: Hashable, Identifiable {
    case allDocuments
    case favorites
    case recent
    case archived
    case project(Project)
    case tag(Tag)
    
    var id: String {
        switch self {
        case .allDocuments: return "all"
        case .favorites: return "favorites"
        case .recent: return "recent"
        case .archived: return "archived"
        case .project(let project): return "project-\(project.id)"
        case .tag(let tag): return "tag-\(tag.id)"
        }
    }
}

// MARK: - Project Row View

struct ProjectRowView: View {
    let project: Project
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDocumentsDrop: ([String]) -> Void
    
    var body: some View {
        NavigationLink(value: SidebarItem.project(project)) {
            Label {
                Text(project.name)
            } icon: {
                Image(systemName: project.iconName)
                    .foregroundStyle(Color(hex: project.colorHex))
            }
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .dropDestination(for: String.self) { droppedIDs, location in
            onDocumentsDrop(droppedIDs)
            return true
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selectedSidebarItem: .constant(.allDocuments))
            .modelContainer(for: [Document.self, Project.self, Tag.self], inMemory: true)
    } detail: {
        Text("Select an item")
    }
}
