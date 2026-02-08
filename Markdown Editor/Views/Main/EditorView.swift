//
//  EditorView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import SwiftData

/// The editor view (third column) with split pane for editing and preview
struct EditorView: View {
    @Bindable var document: Document
    @State private var markdownManager = MarkdownManager.shared
    @State private var showPreview = true
    @State private var previewPosition: PreviewPosition = .trailing
    
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
                            Label("Preview on Right", systemImage: "rectangle.leadinghalf.inset.filled.leading")
                        }
                        
                        Button {
                            previewPosition = .leading
                        } label: {
                            Label("Preview on Left", systemImage: "rectangle.trailinghalf.inset.filled.trailing")
                        }
                        
                        Button {
                            previewPosition = .bottom
                        } label: {
                            Label("Preview Below", systemImage: "rectangle.tophalf.inset.filled.top")
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
    
    private func exportToPDF() async {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "\(document.title).pdf"
        
        let response = await panel.begin()
        guard response == .OK, let url = panel.url else { return }
        
        do {
            try await markdownManager.exportToPDF(markdown: document.content, outputURL: url)
        } catch {
            print("PDF export failed: \(error)")
        }
        #else
        // iOS export implementation
        print("PDF export on iOS requires document picker")
        #endif
    }
    
    private func exportToHTML() async {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = "\(document.title).html"
        
        let response = await panel.begin()
        guard response == .OK, let url = panel.url else { return }
        
        do {
            try await markdownManager.exportToHTML(markdown: document.content, outputURL: url)
        } catch {
            print("HTML export failed: \(error)")
        }
        #else
        // iOS export implementation
        print("HTML export on iOS requires document picker")
        #endif
    }
    
    private func exportToMarkdown() async {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "\(document.title).md"
        panel.allowsOtherFileTypes = true
        
        let response = await panel.begin()
        guard response == .OK, let url = panel.url else { return }
        
        do {
            try await markdownManager.exportToMarkdown(markdown: document.content, outputURL: url)
        } catch {
            print("Markdown export failed: \(error)")
        }
        #else
        // iOS export implementation
        print("Markdown export on iOS requires document picker")
        #endif
    }
}

// MARK: - Preview Position

enum PreviewPosition {
    case leading
    case trailing
    case bottom
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
