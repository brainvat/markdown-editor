# Mac MD - Project Memory

## Project Overview
Mac MD is a modern, Universal Markdown editor for macOS, iOS, and iPadOS, inspired by the classic MacDown application. Built with SwiftUI, SwiftData, and Swift 6 strict concurrency, Mac MD provides a feature-rich editing experience across all Apple platforms.

**Key Features:**
- Live dual-pane Markdown preview with support for CommonMark, GFM, and syntax highlighting
- Flexible preview positioning: Left, Right, Bottom, or detached (separate window on Mac, modal on iPad)
- SwiftData-based document library with CloudKit sync
- Native PDF export (Mac + iOS), HTML/Markdown export (Mac only - iOS blocked by SwiftUI bug)
- Three-column sidebar layout (Projects → Documents → Editor)
- Task list support with interactive checkboxes
- Organizational tools: Projects (folders) and Tags (many-to-many)

## Target Platforms
- macOS 15+
- iOS 18+
- iPadOS 18+

## Key Architecture Decisions

### Data Layer
- **SwiftData** for all persistence (replacing Core Data)
- **CloudKit** integration for cross-device syncing (verified working in v0.3.0)
- Entity models: `Document`, `Snippet`, `Project`, `Tag` (Groups removed in v0.3.0)
- Relationships:
  - Document belongs to one Project (one-to-many)
  - Document has many Tags (many-to-many)
  - Project has many Documents (one-to-many with cascade delete)

### UI Layer
- **SwiftUI** exclusively (no UIKit/AppKit representables unless absolutely necessary)
- **Three-column NavigationSplitView** that collapses intelligently on smaller screens
- **Responsive layouts** that adapt from macOS desktop to iPhone portrait mode

### Rendering & Export
- **MarkdownManager**: Central service for parsing and rendering
- **SPM Dependencies**:
  - Markdown parsing library (Ink or MarkdownUI)
  - Syntax highlighting library
  - MathJax/KaTeX for LaTeX rendering
- **PDFKit** for native PDF generation
- **WKWebView** or custom renderer for live preview

### Concurrency
- Swift 6 strict concurrency mode enabled
- All data operations use `@MainActor` or explicit actors
- Async/await throughout (no completion handlers)

## Important Conventions

### File Organization
```
Markdown Editor/
├── App/
│   └── Markdown_EditorApp.swift
├── Models/
│   ├── Document.swift
│   ├── Snippet.swift
│   ├── Project.swift
│   ├── Tag.swift
│   └── Group.swift
├── Views/
│   ├── Main/
│   │   ├── ContentView.swift
│   │   ├── SidebarView.swift
│   │   ├── DocumentListView.swift
│   │   └── EditorView.swift
│   ├── Preview/
│   │   └── MarkdownPreviewView.swift
│   └── Components/
│       ├── MarkdownEditor.swift
│       └── SyntaxHighlightedText.swift
├── Services/
│   ├── MarkdownManager.swift
│   ├── ExportService.swift
│   └── SyntaxHighlighter.swift
├── Utilities/
│   └── Extensions/
└── Resources/
    └── Assets.xcassets
```

### Naming Conventions
- **Models**: Singular nouns (Document, not Documents)
- **Views**: Descriptive + "View" suffix
- **Services**: Descriptive + "Manager" or "Service" suffix
- **Properties**: camelCase, descriptive names
- **State**: Always `@State private var` for local state

### SwiftData Best Practices
- Use `@Model` macro for all entities
- Define relationships bidirectionally
- Use `@Relationship(deleteRule: .cascade)` where appropriate
- Query with `@Query` in views, filtering at the property wrapper level

### Git Branch Conventions

**Branch Naming Structure:**
- `feature/<feature-name>` - New feature development
- `bugs/<feature-name>-bug-fixes` - Bug fixes for a specific feature
- `hotfix/<description>` - Critical production fixes that go directly to main

**Branch Workflow:**
1. Create feature branch: `git checkout -b feature/v0.2.0`
2. Develop and test feature
3. Merge feature to main when complete
4. If bugs found, create bug fix branch: `git checkout -b bugs/v0.2.0-bug-fixes` from the feature branch or main
5. Fix bugs, then merge bug fix branch to main
6. Hotfixes go directly to main and should be immediately merged back to active feature/bug branches

**Examples:**
- `feature/v0.2.0` - Version 0.2.0 feature development
- `bugs/v0.2.0-bug-fixes` - Bug fixes for v0.2.0 features
- `hotfix/branding-mac-md` - Emergency branding fix

**Rules:**
- Feature branches are prefixed with `feature/` (singular)
- Bug fix branches are prefixed with `bugs/` and suffixed with `-bug-fixes`
- Bug fix branch names should match their parent feature branch name
- Never push directly to main without a merge from a feature/bug/hotfix branch
- Delete branches after successful merge (except long-lived feature branches)

### Development Workflow with Claude

**CRITICAL: Always Wait for User Testing Before Committing**

1. **Make changes** - Write code, update files
2. **Build successfully** - Ensure project builds without errors
3. **STOP and ask user to test** - NEVER commit without explicit user approval
4. **User tests the changes** - User will test on Mac, iPad, etc.
5. **Only after user confirms** - Then proceed with git commit

**Why this matters:**
- User often catches issues during manual testing
- User may want to make tweaks before committing
- Committing untested code wastes git history
- User will explicitly say "okay to commit" or similar

**What to say after building:**
- "Build succeeded! Please test the changes and let me know when you're ready to commit."
- "Ready for testing. Let me know if you find any issues or when you'd like me to commit."
- "Changes complete and building. Test it out and I'll wait for your go-ahead to commit."

**Never say:**
- "Let me commit these changes..." (without asking first)
- "I'll create a commit now..." (without user approval)
- Just silently attempt to commit

## Build/Run Instructions

### Prerequisites
1. Xcode 16+
2. macOS Sequoia or later for development
3. iCloud account for CloudKit testing

### Setup
1. Open `Markdown Editor.xcodeproj`
2. Enable CloudKit capability in Signing & Capabilities
3. Select target device (Mac, iPhone, or iPad)
4. Build and run (⌘R)

### Testing
- Unit tests: `⌘U`
- UI tests: Select UI test target and run
- Preview any SwiftUI view with Xcode Previews (⌥⌘↩)

## Quirks & Gotchas

1. **SwiftData + CloudKit**: Ensure the CloudKit container name matches the bundle identifier. Changes can take time to propagate across devices.

2. **Three-Column Layout**: `NavigationSplitView` behaves differently on iOS vs macOS. Test thoroughly on both platforms.

3. **Markdown Rendering Performance**: Large documents with complex LaTeX can slow down. Implement debouncing on the preview updates.

4. **iPad Split View**: Remember to test in various multitasking modes (Slide Over, Split View).

5. **Syntax Highlighting**: Some libraries don't work well with SwiftUI's `Text`. May need to use `TextEditor` with attributed strings or custom rendering.

6. **PDF Export**: PDFKit is macOS-only. iOS uses `UIGraphicsPDFRenderer`. Abstract this behind a protocol.

7. **File Import/Export**: Use `.fileImporter`/`.fileExporter` modifiers, not old UIDocumentPickerViewController.

## Dependencies (SPM)

Current dependencies:
- ✅ **swift-markdown v0.7.3** - Apple's official Markdown parser (CommonMark + GFM)
- ✅ **Highlight.js 11.9.0** - Syntax highlighting via CDN (185 languages)

To be added:
- [ ] LaTeX/Math rendering (MathJax or KaTeX via CDN)

## Known Issues
- Keyboard shortcuts implemented but need testing across all scenarios
- Export functionality (PDF/HTML) needs implementation
- LaTeX rendering not yet implemented

## Future Enhancements
- [ ] Extensions/Plugins system
- [ ] Custom themes
- [ ] Multi-cursor editing
- [ ] Git integration
- [ ] Collaborative editing
