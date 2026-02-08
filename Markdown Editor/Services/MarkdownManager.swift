//
//  MarkdownManager.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import Foundation
import SwiftUI
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
        // TODO: Integrate actual Markdown parsing library (Ink, MarkdownUI, or swift-markdown)
        // For now, return a basic HTML wrapper
        
        // Basic CommonMark-like transformations (placeholder until we add a real parser)
        var html = markdown
        
        // Headers
        html = html.replacingOccurrences(
            of: #"^### (.+)$"#,
            with: "<h3>$1</h3>",
            options: [.regularExpression, .anchored]
        )
        html = html.replacingOccurrences(
            of: #"^## (.+)$"#,
            with: "<h2>$1</h2>",
            options: [.regularExpression, .anchored]
        )
        html = html.replacingOccurrences(
            of: #"^# (.+)$"#,
            with: "<h1>$1</h1>",
            options: [.regularExpression, .anchored]
        )
        
        // Bold
        html = html.replacingOccurrences(
            of: #"\*\*(.+?)\*\*"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        
        // Italic
        html = html.replacingOccurrences(
            of: #"\*(.+?)\*"#,
            with: "<em>$1</em>",
            options: .regularExpression
        )
        
        // Code blocks
        html = html.replacingOccurrences(
            of: #"`(.+?)`"#,
            with: "<code>$1</code>",
            options: .regularExpression
        )
        
        // Line breaks
        html = html.replacingOccurrences(of: "\n", with: "<br>")
        
        // Wrap in HTML template
        let styledHTML = wrapInHTMLTemplate(html, includeLaTeX: enableLaTeX)
        
        await MainActor.run {
            self.renderedHTML = styledHTML
        }
        
        return styledHTML
    }
    
    /// Wraps HTML content in a complete HTML document with styling
    private func wrapInHTMLTemplate(_ bodyHTML: String, includeLaTeX: Bool = true) -> String {
        let laTeXScripts = includeLaTeX ? """
        <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
        <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        """ : ""
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Markdown Preview</title>
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
                }
                
                pre code {
                    background-color: transparent;
                    padding: 0;
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
        let html = await parseMarkdown(markdown)
        
        // Create a WebView for rendering
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 612, height: 792)) // US Letter size
        
        // Load HTML
        webView.loadHTMLString(html, baseURL: nil)
        
        // Wait for loading to complete
        try await Task.sleep(for: .milliseconds(500))
        
        // Create PDF data
        let pdfData = try await webView.pdf()
        
        // Write to file
        try pdfData.write(to: outputURL)
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
        let html = await parseMarkdown(markdown)
        try html.write(to: outputURL, atomically: true, encoding: .utf8)
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
