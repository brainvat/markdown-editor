//
//  MarkdownManager.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftUI
import Markdown
#if canImport(AppKit)
import AppKit
import PDFKit
#elseif canImport(UIKit)
import UIKit
import PDFKit
#endif

/// Central service for parsing, rendering, and exporting Markdown content
@MainActor
@Observable
final class MarkdownManager {
    
    // MARK: - Observable Properties
    
    /// The rendered HTML output from the latest Markdown parsing
    var renderedHTML: String = ""
    
    /// Any error that occurred during parsing
    var parsingError: Error?
    
    // MARK: - Singleton
    
    static let shared = MarkdownManager()
    
    private init() {}
    
    // MARK: - Markdown Parsing
    
    /// Parses Markdown text and returns HTML
    /// - Parameters:
    ///   - markdown: Raw Markdown string
    ///   - enableGFM: Enable GitHub Flavored Markdown extensions
    ///   - enableLaTeX: Enable LaTeX math rendering
    /// - Returns: Rendered HTML string
    func parseMarkdown(
        _ markdown: String,
        enableGFM: Bool = true,
        enableLaTeX: Bool = true
    ) async -> String {
        // Parse Markdown using swift-markdown
        let document = Markdown.Document(parsing: markdown)
        
        // Convert to HTML
        let html = renderHTML(from: document)
        
        // Wrap in HTML template
        let styledHTML = wrapInHTMLTemplate(html, includeLaTeX: enableLaTeX)
        
        self.renderedHTML = styledHTML
        self.parsingError = nil
        
        return styledHTML
    }
    
    /// Recursively renders Markdown AST nodes to HTML
    private func renderHTML(from markup: Markup) -> String {
        var html = ""
        
        for child in markup.children {
            html += renderNode(child)
        }
        
        return html
    }
    
    /// Renders a single Markdown node to HTML
    private func renderNode(_ node: Markup) -> String {
        switch node {
        // Block elements
        case let heading as Heading:
            let level = heading.level
            let content = renderHTML(from: heading)
            return "<h\(level)>\(content)</h\(level)>\n"
            
        case let paragraph as Paragraph:
            let content = renderHTML(from: paragraph)
            return "<p>\(content)</p>\n"
            
        case let blockQuote as BlockQuote:
            let content = renderHTML(from: blockQuote)
            return "<blockquote>\n\(content)</blockquote>\n"
            
        case let codeBlock as CodeBlock:
            let code = codeBlock.code.htmlEscaped
            let language = codeBlock.language ?? ""
            return "<pre><code class=\"language-\(language)\">\(code)</code></pre>\n"
            
        case let list as UnorderedList:
            let content = renderHTML(from: list)
            return "<ul>\n\(content)</ul>\n"
            
        case let list as OrderedList:
            let start = list.startIndex
            let startAttr = start > 1 ? " start=\"\(start)\"" : ""
            let content = renderHTML(from: list)
            return "<ol\(startAttr)>\n\(content)</ol>\n"
            
        case let listItem as ListItem:
            let content = renderHTML(from: listItem)
            // Check for task list checkbox
            if let checkbox = listItem.checkbox {
                let checked = checkbox == .checked ? " checked" : ""
                return "<li class=\"task-list-item\"><input type=\"checkbox\"\(checked) disabled> \(content)</li>\n"
            }
            return "<li>\(content)</li>\n"
            
        case let table as Markdown.Table:
            var tableHTML = "<table>\n"
            
            // Table head
            let head = table.head
            tableHTML += "<thead>\n<tr>\n"
            for cell in head.cells {
                let content = renderHTML(from: cell)
                tableHTML += "<th>\(content)</th>\n"
            }
            tableHTML += "</tr>\n</thead>\n"
            
            // Table body
            tableHTML += "<tbody>\n"
            for row in table.body.rows {
                tableHTML += "<tr>\n"
                for cell in row.cells {
                    let content = renderHTML(from: cell)
                    tableHTML += "<td>\(content)</td>\n"
                }
                tableHTML += "</tr>\n"
            }
            tableHTML += "</tbody>\n</table>\n"
            
            return tableHTML
            
        case is ThematicBreak:
            return "<hr>\n"
            
        // Inline elements
        case let text as Markdown.Text:
            return text.string.htmlEscaped
            
        case let strong as Strong:
            let content = renderHTML(from: strong)
            return "<strong>\(content)</strong>"
            
        case let emphasis as Emphasis:
            let content = renderHTML(from: emphasis)
            return "<em>\(content)</em>"
            
        case let code as InlineCode:
            return "<code>\(code.code.htmlEscaped)</code>"
            
        case let link as Markdown.Link:
            let url = link.destination?.htmlEscaped ?? ""
            let title = link.title?.htmlEscaped ?? ""
            let titleAttr = title.isEmpty ? "" : " title=\"\(title)\""
            let content = renderHTML(from: link)
            return "<a href=\"\(url)\"\(titleAttr)>\(content)</a>"
            
        case let image as Markdown.Image:
            let url = image.source?.htmlEscaped ?? ""
            let alt = renderHTML(from: image)
            let title = image.title?.htmlEscaped ?? ""
            let titleAttr = title.isEmpty ? "" : " title=\"\(title)\""
            return "<img src=\"\(url)\" alt=\"\(alt)\"\(titleAttr)>"
            
        case let strikethrough as Strikethrough:
            let content = renderHTML(from: strikethrough)
            return "<del>\(content)</del>"
            
        case is SoftBreak:
            return " "
            
        case is LineBreak:
            return "<br>\n"
            
        default:
            // Recursively process unknown node types
            return renderHTML(from: node)
        }
    }
    
    /// Wraps HTML content in a complete HTML document with styling
    private func wrapInHTMLTemplate(_ bodyHTML: String, includeLaTeX: Bool = true) -> String {
        let laTeXScripts = includeLaTeX ? """
        <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
        <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        """ : ""
        
        // Highlight.js for syntax highlighting
        let highlightScripts = """
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css" media="(prefers-color-scheme: light)">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css" media="(prefers-color-scheme: dark)">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
        <script>hljs.highlightAll();</script>
        """
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Markdown Preview</title>
            \(highlightScripts)
            <style>
                :root {
                    color-scheme: light dark;
                }
                
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    background-color: #ffffff;
                }
                
                @media (prefers-color-scheme: dark) {
                    body {
                        color: #e8e8e8;
                        background-color: #1e1e1e;
                    }
                    
                    code {
                        background-color: #2d2d2d;
                        color: #e8e8e8;
                    }
                    
                    pre {
                        background-color: #2d2d2d;
                    }
                }
                
                h1, h2, h3, h4, h5, h6 {
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                    line-height: 1.25;
                }
                
                h1 {
                    font-size: 2em;
                    border-bottom: 1px solid #eaecef;
                    padding-bottom: 0.3em;
                }
                
                h2 {
                    font-size: 1.5em;
                    border-bottom: 1px solid #eaecef;
                    padding-bottom: 0.3em;
                }
                
                h3 { font-size: 1.25em; }
                h4 { font-size: 1em; }
                h5 { font-size: 0.875em; }
                h6 { font-size: 0.85em; color: #6a737d; }
                
                p {
                    margin-top: 0;
                    margin-bottom: 16px;
                }
                
                code {
                    font-family: 'SF Mono', Monaco, 'Courier New', monospace;
                    font-size: 0.9em;
                    padding: 0.2em 0.4em;
                    background-color: rgba(175, 184, 193, 0.2);
                    border-radius: 3px;
                }
                
                pre {
                    font-family: 'SF Mono', Monaco, 'Courier New', monospace;
                    font-size: 0.9em;
                    padding: 16px;
                    overflow: auto;
                    background-color: #f6f8fa;
                    border-radius: 6px;
                    line-height: 1.45;
                    margin-bottom: 16px;
                }
                
                pre code {
                    background-color: transparent;
                    padding: 0;
                    border-radius: 0;
                }
                
                /* Highlight.js overrides for better integration */
                pre code.hljs {
                    padding: 0;
                    background: transparent;
                }
                
                blockquote {
                    margin: 0;
                    padding: 0 1em;
                    color: #6a737d;
                    border-left: 0.25em solid #dfe2e5;
                }
                
                a {
                    color: #0366d6;
                    text-decoration: none;
                }
                
                a:hover {
                    text-decoration: underline;
                }
                
                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin-bottom: 16px;
                }
                
                table th, table td {
                    padding: 6px 13px;
                    border: 1px solid #dfe2e5;
                }
                
                table tr {
                    background-color: #fff;
                    border-top: 1px solid #c6cbd1;
                }
                
                table tr:nth-child(2n) {
                    background-color: #f6f8fa;
                }
                
                ul, ol {
                    margin-top: 0;
                    margin-bottom: 16px;
                    padding-left: 2em;
                }
                
                /* Task list styling */
                ul.task-list {
                    list-style-type: none;
                    padding-left: 0;
                }
                
                ul.task-list li {
                    position: relative;
                    padding-left: 1.5em;
                }
                
                ul.task-list li input[type="checkbox"] {
                    position: absolute;
                    left: 0;
                    margin: 0.3em 0 0 0;
                }
            </style>
            \(laTeXScripts)
        </head>
        <body>
            \(bodyHTML)
        </body>
        </html>
        """
    }
    
    // MARK: - PDF Export
    
    #if canImport(AppKit)
    /// Exports Markdown content as PDF (macOS)
    func exportToPDF(markdown: String, outputURL: URL) async throws {
        print("📄 MarkdownManager: Starting PDF export...")
        print("📄 Content length: \(markdown.count) characters")
        
        let html = await parseMarkdown(markdown)
        print("📄 HTML generated, length: \(html.count) characters")
        
        // Create a WebView for rendering with US Letter width
        let pageWidth: CGFloat = 612 // US Letter width
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: pageWidth, height: 792))
        print("📄 WebView created")
        
        // Load HTML
        webView.loadHTMLString(html, baseURL: nil)
        print("📄 HTML loaded into WebView")
        
        // Wait for loading to complete and content to render
        try await Task.sleep(for: .milliseconds(500))
        
        // Get the actual content height from the WebView
        let contentHeight = try await webView.evaluateJavaScript("document.documentElement.scrollHeight") as? CGFloat ?? 792
        print("📄 Content height calculated: \(contentHeight) points")
        
        // Resize WebView to full content height to capture all pages
        webView.frame = CGRect(x: 0, y: 0, width: pageWidth, height: contentHeight)
        print("📄 WebView resized to full content height")
        
        // Wait a bit more for layout to settle
        try await Task.sleep(for: .milliseconds(200))
        
        // Create PDF data with full content
        let pdfData = try await webView.pdf()
        print("📄 PDF data created, size: \(pdfData.count) bytes")
        
        // Write to file
        try pdfData.write(to: outputURL)
        print("📄 PDF written to file: \(outputURL.path)")
    }
    #else
    /// Exports Markdown content as PDF (iOS/iPadOS)
    func exportToPDF(markdown: String, outputURL: URL) async throws {
        let html = await parseMarkdown(markdown)
        
        // Use UIGraphicsPDFRenderer for iOS
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // Render HTML as attributed string (simplified approach)
            // In production, we'd use WKWebView's PDF capabilities or a more sophisticated renderer
            let htmlData = Data(html.utf8)
            if let attributedString = try? NSAttributedString(
                data: htmlData,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            ) {
                attributedString.draw(in: pageSize.insetBy(dx: 50, dy: 50))
            }
        }
        
        try pdfData.write(to: outputURL)
    }
    #endif
    
    // MARK: - HTML Export
    
    /// Exports Markdown content as standalone HTML file
    func exportToHTML(markdown: String, outputURL: URL) async throws {
        print("🌐 MarkdownManager: Starting HTML export...")
        print("🌐 Content length: \(markdown.count) characters")
        
        let html = await parseMarkdown(markdown)
        print("🌐 HTML generated, length: \(html.count) characters")
        
        try html.write(to: outputURL, atomically: true, encoding: .utf8)
        print("🌐 HTML written to file: \(outputURL.path)")
    }
    
    // MARK: - Markdown Export
    
    /// Exports raw Markdown content as .md file
    func exportToMarkdown(markdown: String, outputURL: URL) async throws {
        print("📝 MarkdownManager: Starting Markdown export...")
        print("📝 Content length: \(markdown.count) characters")
        print("📝 Output URL: \(outputURL.path)")
        
        try markdown.write(to: outputURL, atomically: true, encoding: .utf8)
        print("📝 Markdown written to file successfully")
    }
    
    // MARK: - Task List Support
    
    /// Toggles a checkbox in task list at the given line index
    /// Returns the updated Markdown content
    func toggleTaskListItem(in markdown: String, at lineIndex: Int) -> String {
        var lines = markdown.components(separatedBy: .newlines)
        
        guard lineIndex < lines.count else { return markdown }
        
        let line = lines[lineIndex]
        
        // Check if it's a task list item
        if line.contains("- [ ]") {
            lines[lineIndex] = line.replacingOccurrences(of: "- [ ]", with: "- [x]")
        } else if line.contains("- [x]") {
            lines[lineIndex] = line.replacingOccurrences(of: "- [x]", with: "- [ ]")
        } else if line.contains("- [X]") {
            lines[lineIndex] = line.replacingOccurrences(of: "- [X]", with: "- [ ]")
        }
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - WKWebView Extension for PDF (macOS)

#if canImport(AppKit)
import WebKit

extension WKWebView {
    func pdf() async throws -> Data {
        let config = WKPDFConfiguration()
        config.rect = self.bounds
        
        return try await withCheckedThrowingContinuation { continuation in
            self.createPDF(configuration: config) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
#endif

// MARK: - String HTML Escaping Extension

extension String {
    /// Escapes HTML special characters
    var htmlEscaped: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
