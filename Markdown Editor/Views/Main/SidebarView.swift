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
    @Query private var groups: [Group]
    @Query private var tags: [Tag]
    
    @Binding var selectedSidebarItem: SidebarItem?
    
    var body: some View {
        List(selection: $selectedSidebarItem) {
            // All Documents
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
            }
            
            // Projects
            Section("Projects") {
                ForEach(projects) { project in
                    NavigationLink(value: SidebarItem.project(project)) {
                        Label {
                            Text(project.name)
                        } icon: {
                            Image(systemName: project.iconName)
                                .foregroundStyle(Color(hex: project.colorHex))
                        }
                    }
                }
            }
            
            // Groups (Folders)
            Section("Groups") {
                ForEach(groups.filter { !$0.isNested }) { group in
                    GroupRowView(group: group, selectedItem: $selectedSidebarItem)
                }
            }
            
            // Tags
            Section("Tags") {
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
            }
        }
        .navigationTitle("Mac MD")
        .toolbar {
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
                        createNewGroup()
                    } label: {
                        Label("New Group", systemImage: "folder.badge.plus")
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
        }
    }
    
    // MARK: - Actions
    
    private func createNewDocument() {
        let document = Document(title: "Untitled Document")
        modelContext.insert(document)
    }
    
    private func createNewProject() {
        let project = Project(name: "New Project")
        modelContext.insert(project)
    }
    
    private func createNewGroup() {
        let group = Group(name: "New Group")
        modelContext.insert(group)
    }
    
    private func createNewTag() {
        let tag = Tag(name: "New Tag")
        modelContext.insert(tag)
    }
}

/// Recursive view for displaying groups with subgroups
struct GroupRowView: View {
    let group: Group
    @Binding var selectedItem: SidebarItem?
    
    var body: some View {
        DisclosureGroup {
            ForEach(group.subgroups) { subgroup in
                GroupRowView(group: subgroup, selectedItem: $selectedItem)
            }
        } label: {
            NavigationLink(value: SidebarItem.group(group)) {
                Label {
                    Text(group.name)
                } icon: {
                    Image(systemName: group.iconName)
                        .foregroundStyle(Color(hex: group.colorHex))
                }
            }
        }
    }
}

// MARK: - Sidebar Item

/// Represents the different types of items that can be selected in the sidebar
enum SidebarItem: Hashable, Identifiable {
    case allDocuments
    case favorites
    case recent
    case project(Project)
    case group(Group)
    case tag(Tag)
    
    var id: String {
        switch self {
        case .allDocuments: return "all"
        case .favorites: return "favorites"
        case .recent: return "recent"
        case .project(let project): return "project-\(project.id)"
        case .group(let group): return "group-\(group.id)"
        case .tag(let tag): return "tag-\(tag.id)"
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255
        )
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selectedSidebarItem: .constant(.allDocuments))
            .modelContainer(for: [Document.self, Project.self, Group.self, Tag.self], inMemory: true)
    } detail: {
        Text("Select an item")
    }
}
