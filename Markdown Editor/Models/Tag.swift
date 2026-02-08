//
//  Tag.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftData

/// Represents a tag that can be applied to multiple documents
@Model
final class Tag {
    /// Unique identifier
    var id: UUID
    
    /// Tag name (e.g., "Work", "Personal", "Draft")
    var name: String
    
    /// Optional color for visual identification (hex string)
    var colorHex: String
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Custom sort order
    var sortOrder: Int
    
    // MARK: - Relationships
    
    /// Documents that have this tag (many-to-many)
    @Relationship(deleteRule: .nullify)
    var documents: [Document]
    
    // MARK: - Initialization
    
    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
        self.sortOrder = 0
        self.documents = []
    }
    
    // MARK: - Computed Properties
    
    /// Number of documents with this tag
    var documentCount: Int {
        documents.count
    }
}
