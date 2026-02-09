//
//  TagEditSheet.swift
//  Markdown Editor
//
//  Created by ahammock on 2/8/26.
//

import SwiftUI
import SwiftData

/// Sheet for creating or editing a tag
struct TagEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let tag: Tag?
    
    @State private var name: String
    @State private var selectedColor: Color
    
    private var isEditing: Bool {
        tag != nil
    }
    
    init(tag: Tag?) {
        self.tag = tag
        _name = State(initialValue: tag?.name ?? "New Tag")
        _selectedColor = State(initialValue: Color(hex: tag?.colorHex ?? "#007AFF"))
    }
    
    var body: some View {
        #if os(macOS)
        macOSContent
        #else
        iOSContent
        #endif
    }
    
    // MARK: - macOS Layout
    
    private var macOSContent: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text(isEditing ? "Edit Tag" : "New Tag")
                    .font(.headline)
                    .padding()
                Spacer()
            }
            #if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(uiColor: .secondarySystemBackground))
            #endif
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tag Name")
                            .font(.headline)
                        
                        TextField("Tag name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Color section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            // Preview circle
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 32, height: 32)
                            
                            ColorPicker("Select color", selection: $selectedColor, supportsOpacity: false)
                                .labelsHidden()
                        }
                    }
                    
                    // Document count (if editing)
                    if let tag = tag {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Documents")
                                .font(.headline)
                            
                            Text("\(tag.documents.count) document(s) tagged")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Bottom buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(isEditing ? "Save" : "Create") {
                    saveTag()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            #if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(uiColor: .secondarySystemBackground))
            #endif
        }
        .frame(width: 480, height: 400)
    }
    
    // MARK: - iOS Layout
    
    private var iOSContent: some View {
        NavigationStack {
            Form {
                Section("Information") {
                    TextField("Tag Name", text: $name)
                }
                
                Section("Color") {
                    HStack {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 32, height: 32)
                        
                        ColorPicker("Tag Color", selection: $selectedColor, supportsOpacity: false)
                    }
                }
                
                if let tag = tag {
                    Section("Documents") {
                        Text("\(tag.documents.count) document(s) tagged")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Tag" : "New Tag")
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
                    Button(isEditing ? "Save" : "Create") {
                        saveTag()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveTag() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let tag = tag {
            // Update existing tag
            tag.name = trimmedName
            tag.colorHex = selectedColor.toHex()
        } else {
            // Create new tag
            let newTag = Tag(name: trimmedName, colorHex: selectedColor.toHex())
            modelContext.insert(newTag)
        }
        
        dismiss()
    }
}

#Preview("New Tag") {
    TagEditSheet(tag: nil)
        .modelContainer(for: Tag.self, inMemory: true)
}

#Preview("Edit Tag") {
    @Previewable @State var sampleTag = Tag(name: "Important", colorHex: "#FF0000")
    
    TagEditSheet(tag: sampleTag)
        .modelContainer(for: Tag.self, inMemory: true)
}
