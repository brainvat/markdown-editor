//
//  Project.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftData

/// Represents a collection of related documents (e.g., a book, blog series, course)
@Model
final class Project {
    /// Unique identifier
    var id: UUID
    
    /// Project name
    var name: String
    
    /// Project description
    var projectDescription: String
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last modification timestamp
    var modifiedAt: Date
    
    /// Project color for visual identification (hex string)
    var colorHex: String
    
    /// Custom icon name (SF Symbol)
    var iconName: String
    
    /// Whether the project is archived
    var isArchived: Bool
    
    /// Custom sort order
    var sortOrder: Int
    
    // MARK: - Relationships
    
    /// Documents that belong to this project
    @Relationship(deleteRule: .nullify)
    var documents: [Document]
    
    /// Snippets associated with this project
    @Relationship(deleteRule: .nullify)
    var snippets: [Snippet]
    
    // MARK: - Initialization
    
    init(
        name: String,
        projectDescription: String = "",
        colorHex: String = "#007AFF",
        iconName: String = "folder"
    ) {
        self.id = UUID()
        self.name = name
        self.projectDescription = projectDescription
        let now = Date()
        self.createdAt = now
        self.modifiedAt = now
        self.colorHex = colorHex
        self.iconName = iconName
        self.isArchived = false
        self.sortOrder = 0
        self.documents = []
        self.snippets = []
    }
    
    // MARK: - Computed Properties
    
    /// Total number of documents in the project
    var documentCount: Int {
        documents.count
    }
    
    /// Total word count across all documents
    var totalWordCount: Int {
        documents.reduce(0) { $0 + $1.wordCount }
    }
}
