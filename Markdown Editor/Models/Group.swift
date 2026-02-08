//
//  Group.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftData

/// Represents a folder/group for organizing documents (like Xcode groups)
@Model
final class Group {
    /// Unique identifier
    var id: UUID
    
    /// Group name (e.g., "Work", "Blog Posts", "Notes")
    var name: String
    
    /// Optional group description
    var groupDescription: String
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Custom icon name (SF Symbol)
    var iconName: String
    
    /// Custom color for visual identification (hex string)
    var colorHex: String
    
    /// Custom sort order
    var sortOrder: Int
    
    // MARK: - Relationships
    
    /// Documents in this group
    @Relationship(deleteRule: .nullify)
    var documents: [Document]
    
    /// Parent group (for nested groups/folders)
    @Relationship(deleteRule: .nullify, inverse: \Group.subgroups)
    var parentGroup: Group?
    
    /// Child groups (for nested groups/folders)
    @Relationship(deleteRule: .cascade)
    var subgroups: [Group]
    
    // MARK: - Initialization
    
    init(
        name: String,
        groupDescription: String = "",
        iconName: String = "folder",
        colorHex: String = "#FFD60A",
        parentGroup: Group? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.groupDescription = groupDescription
        self.createdAt = Date()
        self.iconName = iconName
        self.colorHex = colorHex
        self.sortOrder = 0
        self.documents = []
        self.subgroups = []
        self.parentGroup = parentGroup
    }
    
    // MARK: - Computed Properties
    
    /// Total number of documents in this group (excluding subgroups)
    var documentCount: Int {
        documents.count
    }
    
    /// Total number of documents including all subgroups
    var totalDocumentCount: Int {
        documents.count + subgroups.reduce(0) { $0 + $1.totalDocumentCount }
    }
    
    /// Whether this group has a parent
    var isNested: Bool {
        parentGroup != nil
    }
}
