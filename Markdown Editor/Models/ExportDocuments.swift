//
//  ExportDocuments.swift
//  Markdown Editor
//
//  Created by Claude on 2/8/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Markdown Document

/// FileDocument for exporting Markdown (.md) files
struct MarkdownExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    static var writableContentTypes: [UTType] { [.plainText] }
    
    var content: String
    var filename: String
    
    init(content: String, filename: String) {
        self.content = content
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = string
        self.filename = configuration.file.filename ?? "document.md"
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(content.utf8)
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.filename = filename
        return wrapper
    }
}

// MARK: - HTML Document

/// FileDocument for exporting HTML files
struct HTMLExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.html] }
    static var writableContentTypes: [UTType] { [.html] }
    
    var content: String
    var filename: String
    
    init(content: String, filename: String) {
        self.content = content
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = string
        self.filename = configuration.file.filename ?? "document.html"
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(content.utf8)
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.filename = filename
        return wrapper
    }
}

// MARK: - PDF Document

/// FileDocument for exporting PDF files
struct PDFExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    static var writableContentTypes: [UTType] { [.pdf] }
    
    var data: Data
    var filename: String
    
    init(data: Data, filename: String) {
        self.data = data
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
        self.filename = configuration.file.filename ?? "document.pdf"
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.filename = filename
        return wrapper
    }
}
