//
//  EditorView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// The editor view (third column) with split pane for editing and preview
struct EditorView: View {
    @Bindable var document: Document
    @State private var markdownManager = MarkdownManager.shared
    @State private var showPreview = true
    @State private var previewPosition: PreviewPosition = .trailing
    
    // iOS export state
    @State private var showingMarkdownExport = false
    @State private var showingPDFExport = false
    @State private var showingHTMLExport = false
    @State private var exportDocument: ExportDocument?
    
    var body: some View {
        GeometryReader { geometry in
            if showPreview {
                splitView(width: geometry.size.width)
            } else {
                editorOnlyView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .togglePreview)) { _ in
            withAnimation {
                showPreview.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .previewPositionTrailing)) { _ in
            previewPosition = .trailing
        }
        .onReceive(NotificationCenter.default.publisher(for: .previewPositionLeading)) { _ in
            previewPosition = .leading
        }
        .onReceive(NotificationCenter.default.publisher(for: .previewPositionBottom)) { _ in
            previewPosition = .bottom
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportToMarkdown)) { _ in
            Task {
                await exportToMarkdown()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportToPDF)) { _ in
            Task {
                await exportToPDF()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportToHTML)) { _ in
            Task {
                await exportToHTML()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                // Preview toggle
                Button {
                    withAnimation {
                        showPreview.toggle()
                    }
                } label: {
                    Label(
                        showPreview ? "Hide Preview" : "Show Preview",
                        systemImage: showPreview ? "eye.slash" : "eye"
                    )
                }
                
                // Preview position (only when preview is visible)
                if showPreview {
                    Menu {
                        Button {
                            previewPosition = .trailing
                        } label: {
                            Label("Preview on Right", systemImage: "sidebar.right")
                        }
                        
                        Button {
                            previewPosition = .leading
                        } label: {
                            Label("Preview on Left", systemImage: "sidebar.left")
                        }
                        
                        Button {
                            previewPosition = .bottom
                        } label: {
                            Label("Preview Below", systemImage: "rectangle.split.1x2")
                        }
                    } label: {
                        Label("Preview Position", systemImage: "rectangle.split.2x1")
                    }
                }
                
                Divider()
                
                // Export menu
                Menu {
                    Button {
                        Task {
                            await exportToMarkdown()
                        }
                    } label: {
                        Label("Export as Markdown", systemImage: "doc.text")
                    }
                    
                    Button {
                        Task {
                            await exportToPDF()
                        }
                    } label: {
                        Label("Export as PDF", systemImage: "doc.richtext")
                    }
                    
                    Button {
                        Task {
                            await exportToHTML()
                        }
                    } label: {
                        Label("Export as HTML", systemImage: "globe")
                    }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle(document.title)
        .task {
            // Mark document as accessed when opened
            document.markAsAccessed()
            
            // Initial render
            await updatePreview()
        }
        #if !canImport(AppKit)
        .fileExporter(
            isPresented: $showingMarkdownExport,
            document: exportDocument,
            contentType: .plainText,
            defaultFilename: "\(document.title).md"
        ) { result in
            handleExportResult(result, type: "Markdown")
        }
        .fileExporter(
            isPresented: $showingPDFExport,
            document: exportDocument,
            contentType: .html,
            defaultFilename: "\(document.title).html"
        ) { result in
            handleExportResult(result, type: "PDF (as HTML)")
        }
        .fileExporter(
            isPresented: $showingHTMLExport,
            document: exportDocument,
            contentType: .html,
            defaultFilename: "\(document.title).html"
        ) { result in
            handleExportResult(result, type: "HTML")
        }
        #endif
    }
    
    private func handleExportResult(_ result: Result<URL, Error>, type: String) {
        switch result {
        case .success(let url):
            print("✅ \(type) export successful to: \(url.path)")
        case .failure(let error):
            print("❌ \(type) export failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func splitView(width: CGFloat) -> some View {
        #if os(macOS)
        // macOS uses native split views
        switch previewPosition {
        case .trailing, .leading:
            HSplitView {
                if previewPosition == .leading {
                    previewPane
                    editorPane
                } else {
                    editorPane
                    previewPane
                }
            }
        case .bottom:
            VSplitView {
                editorPane
                previewPane
            }
        }
        #else
        // iOS/iPadOS uses adaptive layout
        switch previewPosition {
        case .trailing, .leading:
            HStack(spacing: 0) {
                if previewPosition == .leading {
                    previewPane
                        .frame(width: width / 2)
                    Divider()
                    editorPane
                        .frame(width: width / 2)
                } else {
                    editorPane
                        .frame(width: width / 2)
                    Divider()
                    previewPane
                        .frame(width: width / 2)
                }
            }
        case .bottom:
            VStack(spacing: 0) {
                editorPane
                Divider()
                previewPane
            }
        }
        #endif
    }
    
    private var editorOnlyView: some View {
        editorPane
    }
    
    private var editorPane: some View {
        VStack(spacing: 0) {
            // Title and Stats bar
            VStack(spacing: 8) {
                // Editable title
                TextField("Document Title", text: $document.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Stats bar
                HStack {
                    Text("\(document.wordCount) words")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("\(document.characterCount) characters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    RelativeTimestampView(date: document.modifiedAt)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            #if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(uiColor: .secondarySystemBackground))
            #endif
            
            // Editor
            TextEditor(text: $document.content)
                .font(.system(.body, design: .monospaced))
                .padding()
                .onChange(of: document.content) { oldValue, newValue in
                    document.updateMetrics()
                    
                    // Debounce preview updates
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        await updatePreview()
                    }
                }
        }
    }
    
    private var previewPane: some View {
        MarkdownPreviewView(html: markdownManager.renderedHTML)
    }
    
    // MARK: - Actions
    
    private func updatePreview() async {
        _ = await markdownManager.parseMarkdown(document.content)
    }
    
    @MainActor
    private func exportToPDF() async {
        #if canImport(AppKit)
        print("📄 Export PDF button clicked!")
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "\(document.title).pdf"
        panel.canCreateDirectories = true
        
        print("📄 Opening PDF save panel...")
        
        let response = await panel.begin()
        print("📄 Panel closed with response: \(response.rawValue)")
        
        guard response == .OK else {
            print("📄 PDF export cancelled by user")
            return
        }
        
        guard let url = panel.url else {
            print("📄 No URL selected - this shouldn't happen!")
            return
        }
        
        print("📄 User selected: \(url.path)")
        print("📄 Starting export process...")
        
        do {
            try await markdownManager.exportToPDF(markdown: document.content, outputURL: url)
            print("✅ PDF export completed successfully!")
        } catch {
            print("❌ PDF export failed with error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
        #else
        // iOS PDF export - Export as HTML instead (iOS doesn't support direct PDF generation via fileExporter)
        print("📄 iOS: Exporting as HTML (PDF generation not supported on iOS via fileExporter)")
        let html = await markdownManager.parseMarkdown(document.content)
        let doc = ExportDocument(content: html, filename: "\(document.title).html", contentType: .html)
        exportDocument = doc
        print("📄 Document created, showing exporter")
        showingPDFExport = true
        print("📄 Exporter flag set to: \(showingPDFExport)")
        #endif
    }
    
    @MainActor
    private func exportToHTML() async {
        #if canImport(AppKit)
        print("🌐 Export HTML button clicked!")
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = "\(document.title).html"
        panel.canCreateDirectories = true
        
        print("🌐 Opening HTML save panel...")
        
        let response = await panel.begin()
        print("🌐 Panel closed with response: \(response.rawValue)")
        
        guard response == .OK else {
            print("🌐 HTML export cancelled by user")
            return
        }
        
        guard let url = panel.url else {
            print("🌐 No URL selected - this shouldn't happen!")
            return
        }
        
        print("🌐 User selected: \(url.path)")
        print("🌐 Starting export process...")
        
        do {
            try await markdownManager.exportToHTML(markdown: document.content, outputURL: url)
            print("✅ HTML export completed successfully!")
        } catch {
            print("❌ HTML export failed with error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
        #else
        // iOS export implementation
        print("🌐 iOS HTML export")
        let html = await markdownManager.parseMarkdown(document.content)
        exportDocument = ExportDocument(content: html, filename: "\(document.title).html", contentType: .html)
        showingHTMLExport = true
        #endif
    }
    
    @MainActor
    private func exportToMarkdown() async {
        #if canImport(AppKit)
        print("📝 Export Markdown button clicked!")
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "\(document.title).md"
        panel.allowsOtherFileTypes = true
        panel.canCreateDirectories = true
        
        print("📝 Opening Markdown save panel...")
        
        let response = await panel.begin()
        print("📝 Panel closed with response: \(response.rawValue)")
        
        guard response == .OK else {
            print("📝 Markdown export cancelled by user")
            return
        }
        
        guard let url = panel.url else {
            print("📝 No URL selected - this shouldn't happen!")
            return
        }
        
        print("📝 User selected: \(url.path)")
        print("📝 Starting export process...")
        
        do {
            try await markdownManager.exportToMarkdown(markdown: document.content, outputURL: url)
            print("✅ Markdown export completed successfully!")
        } catch {
            print("❌ Markdown export failed with error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
        #else
        // iOS export implementation
        print("📝 iOS Markdown export - preparing document")
        let doc = ExportDocument(content: document.content, filename: "\(document.title).md", contentType: .plainText)
        exportDocument = doc
        print("📝 Document created, showing exporter")
        showingMarkdownExport = true
        print("📝 Exporter flag set to: \(showingMarkdownExport)")
        #endif
    }
}

// MARK: - Preview Position

enum PreviewPosition {
    case leading
    case trailing
    case bottom
}

// MARK: - Export Document

/// Wrapper for file export on iOS
struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .pdf, .html] }
    
    let content: String
    let filename: String
    let contentType: UTType
    
    init(content: String, filename: String, contentType: UTType) {
        self.content = content
        self.filename = filename
        self.contentType = contentType
    }
    
    init(configuration: ReadConfiguration) throws {
        fatalError("Reading not supported")
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Relative Timestamp View

/// A view that displays relative time (e.g., "2 minutes ago") but only updates every minute to avoid constant UI refreshes
struct RelativeTimestampView: View {
    let date: Date
    @State private var displayText = ""
    
    var body: some View {
        Text(displayText)
            .font(.caption)
            .foregroundStyle(.secondary)
            .onAppear {
                updateDisplayText()
            }
            .task {
                // Update every minute instead of constantly
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(60))
                    updateDisplayText()
                }
            }
    }
    
    private func updateDisplayText() {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        displayText = "Modified \(formatter.localizedString(for: date, relativeTo: Date()))"
    }
}

#Preview {
    @Previewable @State var document = Document(
        title: "Sample Document",
        content: """
        # Hello World
        
        This is a **sample** Markdown document.
        
        - Item 1
        - Item 2
        - Item 3
        """
    )
    
    NavigationStack {
        EditorView(document: document)
    }
    .modelContainer(for: Document.self, inMemory: true)
}
