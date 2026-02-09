//
//  Document.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftData

/// Represents a Markdown document with full editing history and metadata
@Model
final class Document {
    /// Unique identifier
    var id: UUID
    
    /// Document title (derived from filename or first line)
    var title: String
    
    /// Raw Markdown content
    var content: String
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last modification timestamp
    var modifiedAt: Date
    
    /// Last accessed timestamp (for sorting by recency)
    var lastAccessedAt: Date
    
    /// Whether the document is marked as favorite
    var isFavorite: Bool
    
    /// Whether the document is archived
    var isArchived: Bool
    
    /// Word count (computed on save for performance)
    var wordCount: Int
    
    /// Character count (computed on save for performance)
    var characterCount: Int
    
    /// Optional custom sort order within a group
    var sortOrder: Int
    
    // MARK: - Relationships
    
    /// Tags associated with this document (many-to-many)
    @Relationship(deleteRule: .nullify, inverse: \Tag.documents)
    var tags: [Tag]
    
    /// The project this document belongs to (optional)
    @Relationship(deleteRule: .nullify, inverse: \Project.documents)
    var project: Project?
    
    // MARK: - Initialization
    
    init(
        title: String = "Untitled",
        content: String = "",
        tags: [Tag] = [],
        project: Project? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        let now = Date()
        self.createdAt = now
        self.modifiedAt = now
        self.lastAccessedAt = now
        self.isFavorite = false
        self.isArchived = false
        self.wordCount = 0
        self.characterCount = content.count
        self.sortOrder = 0
        self.tags = tags
        self.project = project
        
        // Compute initial word count
        updateMetrics()
    }
    
    // MARK: - Methods
    
    /// Updates word count and character count based on current content
    func updateMetrics() {
        self.characterCount = content.count
        self.wordCount = content.split { $0.isWhitespace || $0.isNewline }.count
        self.modifiedAt = Date()
    }
    
    /// Marks the document as accessed (updates lastAccessedAt)
    func markAsAccessed() {
        self.lastAccessedAt = Date()
    }
}
