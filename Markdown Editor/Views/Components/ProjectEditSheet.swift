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
        #if os(macOS)
        macOSContent
        #else
        iOSContent
        #endif
    }
    
    // MARK: - iOS Content
    
    private var iOSContent: some View {
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
    
    // MARK: - macOS Content
    
    private var macOSContent: some View {
        VStack(spacing: 0) {
            // Title Bar
            HStack {
                Text(project == nil ? "New Project" : "Edit Project")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(.background.secondary)
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Project Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Project Information")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $projectDescription)
                                .frame(height: 60)
                                .font(.body)
                                .border(Color.secondary.opacity(0.3), width: 1)
                        }
                    }
                    
                    Divider()
                    
                    // Icon Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 8) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    iconName = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(iconName == icon ? Color(hex: colorHex) : .secondary)
                                        .frame(width: 50, height: 50)
                                        .background(iconName == icon ? Color(hex: colorHex).opacity(0.15) : Color.secondary.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(iconName == icon ? Color(hex: colorHex) : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Color Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.headline)
                        
                        ColorPicker("Project Color", selection: Binding(
                            get: { Color(hex: colorHex) },
                            set: { newColor in
                                colorHex = newColor.toHex()
                            }
                        ))
                        .labelsHidden()
                    }
                    
                    // Archived Toggle (only for existing projects)
                    if project != nil {
                        Divider()
                        
                        Toggle("Archived", isOn: $isArchived)
                    }
                }
                .padding(20)
            }
            
            Divider()
            
            // Bottom Buttons
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    saveProject()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
            }
            .padding()
            .background(.background.secondary)
        }
        .frame(width: 480, height: 600)
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

#Preview {
    ProjectEditSheet()
        .modelContainer(for: Project.self, inMemory: true)
}
