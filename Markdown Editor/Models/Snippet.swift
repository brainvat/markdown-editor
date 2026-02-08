//
//  Snippet.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftData

/// Represents a reusable snippet of Markdown or code
@Model
final class Snippet {
    /// Unique identifier
    var id: UUID
    
    /// Snippet title/name
    var title: String
    
    /// The actual snippet content
    var content: String
    
    /// Optional shortcut key for quick insertion (e.g., "sig" for signature)
    var shortcut: String?
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last modification timestamp
    var modifiedAt: Date
    
    /// Last used timestamp (for sorting by frequency)
    var lastUsedAt: Date?
    
    /// Usage count (incremented each time the snippet is inserted)
    var usageCount: Int
    
    /// Category/type of snippet (e.g., "Code", "Template", "Signature")
    var category: String
    
    /// Custom sort order
    var sortOrder: Int
    
    // MARK: - Relationships
    
    /// The project this snippet belongs to (optional)
    @Relationship(deleteRule: .nullify, inverse: \Project.snippets)
    var project: Project?
    
    // MARK: - Initialization
    
    init(
        title: String,
        content: String,
        shortcut: String? = nil,
        category: String = "General",
        project: Project? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.shortcut = shortcut
        let now = Date()
        self.createdAt = now
        self.modifiedAt = now
        self.lastUsedAt = nil
        self.usageCount = 0
        self.category = category
        self.sortOrder = 0
        self.project = project
    }
    
    // MARK: - Methods
    
    /// Records a usage of this snippet
    func recordUsage() {
        self.usageCount += 1
        self.lastUsedAt = Date()
    }
}
