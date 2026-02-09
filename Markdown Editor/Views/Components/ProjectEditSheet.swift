//
//  ProjectEditSheet.swift
//  Markdown Editor
//
//  Created by ahammock on 2/8/26.
//

import SwiftUI
import SwiftData

/// Sheet for creating or editing a project
struct ProjectEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let project: Project?
    
    @State private var name: String
    @State private var projectDescription: String
    @State private var colorHex: String
    @State private var iconName: String
    @State private var isArchived: Bool
    
    private let availableIcons = [
        "folder", "folder.fill", "star", "star.fill",
        "book", "book.fill", "doc.text", "doc.text.fill",
        "text.book.closed", "text.book.closed.fill",
        "briefcase", "briefcase.fill", "folder.badge.person.crop",
        "pencil", "pencil.circle", "globe", "lightbulb"
    ]
    
    init(project: Project? = nil) {
        self.project = project
        _name = State(initialValue: project?.name ?? "")
        _projectDescription = State(initialValue: project?.projectDescription ?? "")
        _colorHex = State(initialValue: project?.colorHex ?? "#007AFF")
        _iconName = State(initialValue: project?.iconName ?? "folder.fill")
        _isArchived = State(initialValue: project?.isArchived ?? false)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Project Information") {
                    TextField("Name", text: $name)
                        .textFieldStyle(.plain)
                    
                    TextField("Description (Optional)", text: $projectDescription, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(3...6)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                iconName = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title)
                                    .foregroundStyle(iconName == icon ? Color(hex: colorHex) : .secondary)
                                    .frame(width: 60, height: 60)
                                    .background(iconName == icon ? Color(hex: colorHex).opacity(0.1) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Color") {
                    ColorPicker("Project Color", selection: Binding(
                        get: { Color(hex: colorHex) },
                        set: { newColor in
                            colorHex = newColor.toHex()
                        }
                    ))
                }
                
                if project != nil {
                    Section {
                        Toggle("Archived", isOn: $isArchived)
                    }
                }
            }
            .navigationTitle(project == nil ? "New Project" : "Edit Project")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveProject() {
        if let project = project {
            // Update existing project
            project.name = name
            project.projectDescription = projectDescription
            project.colorHex = colorHex
            project.iconName = iconName
            project.isArchived = isArchived
            project.modifiedAt = Date()
        } else {
            // Create new project
            let newProject = Project(
                name: name,
                projectDescription: projectDescription,
                colorHex: colorHex,
                iconName: iconName
            )
            newProject.isArchived = isArchived
            modelContext.insert(newProject)
        }
        
        dismiss()
    }
}

// Extension to convert Color to hex string
extension Color {
    func toHex() -> String {
        #if os(iOS)
        let nativeColor = UIColor(self)
        #else
        let nativeColor = NSColor(self)
        #endif
        
        guard let components = nativeColor.cgColor.components else { return "#000000" }
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : components[0]
        let b = components.count > 2 ? components[2] : components[0]
        
        return String(format: "#%02X%02X%02X",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
}

#Preview {
    ProjectEditSheet()
        .modelContainer(for: Project.self, inMemory: true)
}
