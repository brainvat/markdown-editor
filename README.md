# Mac MD

<img src="mac_md.png" alt="Mac MD Logo" width="200"/>

A modern, feature-rich Markdown editor for macOS, iOS, and iPadOS built with SwiftUI and SwiftData. Mac MD is a Universal App that provides seamless iCloud syncing across all your Apple devices.

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20iPadOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### Core Functionality
- 📝 **Live Markdown Preview** - Real-time rendering with GitHub Flavored Markdown support
- 🎨 **Three-Column Layout** - Sidebar, document list, and editor with adjustable preview
- ☁️ **iCloud Sync** - Seamless synchronization across all your devices via CloudKit
- 📱 **Universal App** - Native experience on Mac, iPad, and iPhone
- 🌓 **Dark Mode** - Beautiful styling that adapts to system appearance

### Document Organization
- 📂 **Projects** - Group related documents together with icons and colors
- 🏷️ **Tags** - Flexible many-to-many tagging system with colored badges
- ⭐ **Favorites** - Quick access to important documents
- 🕐 **Recents** - Smart collection of recently accessed documents
- 📦 **Archived** - Hide completed documents without deleting

### Markdown Support
- ✅ **CommonMark** - Full standard Markdown support
- 🔧 **GitHub Flavored Markdown** - Tables, task lists, and more
- 🧮 **LaTeX/Math** - Mathematical expressions via MathJax
- 💻 **Syntax Highlighting** - Beautiful code blocks (coming soon)
- 📋 **Smart Lists** - Auto-continuation and task list toggling

### Export & Sharing
- 📄 **PDF Export** - Native PDF generation with styling preservation (Mac: ✅ iOS: ✅)
- 🌐 **HTML Export** - Standalone HTML files with embedded CSS (Mac: ✅ iOS: ❌ SwiftUI bug)
- 📝 **Markdown Export** - Export as .md files (Mac: ✅ iOS: ❌ SwiftUI bug)
- 📊 **Document Stats** - Word count, character count, last modified

**Note:** iOS HTML and Markdown exports are blocked by a [confirmed SwiftUI framework bug](docs/bug-reports/APPLE_BUG_REPORT_SWIFTUI_FILEEXPORTER.md) where `.fileExporter()` silently fails for certain `FileDocument` types despite valid documents being created.

## 🚀 Getting Started

### Requirements
- macOS 15.0+ (Sequoia)
- iOS 18.0+
- iPadOS 18.0+
- Xcode 16.0+
- Swift 6.0+

### Installation

1. Clone the repository:
```bash
git clone git@github.com:brainvat/markdown-editor.git
cd markdown-editor
```

2. Open in Xcode:
```bash
open "Markdown Editor.xcodeproj"
```

3. Select your target platform (Mac, iPhone, or iPad)

4. Build and run (⌘R)

### First Run

On first launch, Mac MD will:
- Request iCloud permissions for syncing (optional)
- Create a sample document to get you started
- Display the three-column layout

## 🏗️ Architecture

Mac MD follows modern Swift and SwiftUI best practices:

### Data Layer
- **SwiftData** for local persistence with `@Model` macro
- **CloudKit** integration for automatic iCloud syncing (disabled for development)
- Four core entities: `Document`, `Tag`, `Project`, `Snippet`
- Bidirectional relationships with proper cascade rules

### UI Layer
- **SwiftUI** exclusively - no UIKit/AppKit representables (except WebView)
- **NavigationSplitView** for adaptive three-column layout
- **@Observable** macro for reactive state management
- Platform-specific adaptations where needed

### Service Layer
- **MarkdownManager** - Centralized Markdown parsing and rendering (@MainActor)
- **Export Services** - PDF and HTML generation
- Async/await throughout (Swift 6 strict concurrency)

### Project Structure
```
Markdown Editor/
├── Models/              # SwiftData entities
│   ├── Document.swift
│   ├── Tag.swift
│   ├── Project.swift
│   └── Snippet.swift
├── Views/
│   ├── Main/           # Three-column layout
│   ├── Preview/        # WebKit-based renderer
│   └── Components/     # Reusable sheets and dialogs
├── Services/           # Business logic
├── Utilities/          # Extensions and helpers
└── App/                # Entry point
```

## 🎓 Inspiration & Credits

This project stands on the shoulders of giants and wouldn't exist without these amazing resources:

### Primary Inspirations

**[MacDown](https://macdown.app)** by [Tzu-ping Chung](https://github.com/uranusjr)
- The original MacDown is a beloved open-source Markdown editor for macOS
- Mac MD was inspired by MacDown's elegant approach to Markdown editing
- Mac MD brings a similar experience to iOS/iPadOS with modern SwiftUI and iCloud sync
- If you're on macOS only, definitely check out the original MacDown!

**[Xcode 26.3 Intelligence Tutorial](https://www.youtube.com/watch?v=QdpaI_j0FRU)** by [Stewart Lynch](https://www.youtube.com/@StewartLynch)
- Incredible tutorial on using Xcode Intelligence (Claude integration) for SwiftUI development
- Demonstrated modern SwiftData patterns and cross-platform development
- Inspiration for leveraging AI assistance in iOS development
- [Stewart's YouTube Channel](https://www.youtube.com/@StewartLynch) is an amazing resource

### AI Agent Development

**[SwiftAgents](https://github.com/twostraws/SwiftAgents)** by [Paul Hudson](https://github.com/twostraws)
- AGENTS.md file that defines how AI should work with Swift projects
- Best practices for AI-assisted Swift development
- Check out Paul's work at [Hacking with Swift](https://www.hackingwithswift.com)

**[SwiftUI Agent Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill)** by [Antoine van der Lee](https://github.com/AvdLee)
- Comprehensive Claude skills for SwiftUI development
- Detailed patterns for modern SwiftUI best practices
- [Antoine's blog](https://www.avanderlee.com) is essential reading for iOS developers

### Development Tools

- **[Claude](https://claude.ai)** by Anthropic - AI pair programming assistant
- **SwiftUI** & **SwiftData** by Apple - Modern app development framework
- **Xcode** - The amazing IDE that makes iOS development possible

## 🤝 Contributing

Contributions are welcome! This project is a learning experience and showcase of modern Swift development.

### Areas for Contribution
- [ ] Integration of proper Markdown parser (Ink, swift-markdown, or MarkdownUI)
- [ ] Syntax highlighting for code blocks
- [ ] Editor intelligence (auto-completion, smart typing)
- [ ] Keyboard shortcuts
- [ ] Search functionality
- [ ] Custom themes
- [ ] Extensions/plugins system

### Guidelines
- Follow Swift API Design Guidelines
- Use Swift 6 strict concurrency
- Write SwiftUI-native code
- Include Xcode Previews for all views
- Update documentation (CLAUDE.md and Journal.md)

## 📖 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Project memory, architecture decisions, and conventions
- **[Journal.md](Journal.md)** - Engineering journey with lessons learned and best practices
- **[IDEA.md](IDEA.md)** - Original project specification

## 🗺️ Roadmap

### v0.1.0-alpha ✅
- [x] SwiftData schema with 5 models
- [x] Three-column layout
- [x] Basic Markdown rendering
- [x] Live preview
- [ ] CloudKit syncing (not working)
- [x] PDF/HTML export

### v0.2.0 (Current) ✅
- [x] Integrate swift-markdown parser (v0.7.3)
- [x] Syntax highlighting via Highlight.js (185 languages)
- [x] Keyboard shortcuts for all export types
- [x] Editable document titles
- [x] Smart timestamp display (updates every 60 seconds)
- [x] Markdown export (.md files) - Mac only due to SwiftUI bug
- [x] HTML export - Mac only due to SwiftUI bug
- [x] PDF export - Both Mac and iOS working
- [x] Mac native file pickers (NSSavePanel)
- [x] Platform-specific export implementations using FileDocument pattern
- [x] Comprehensive testing proving SwiftUI .fileExporter() bug on iOS ([see bug report](docs/bug-reports/APPLE_BUG_REPORT_SWIFTUI_FILEEXPORTER.md))

### v0.3.0 - Complete CRUD Operations ✅
**Goal:** Simplified data model with complete document management

**Data Model Simplification** ✅
- [x] Remove Group entity entirely (use Projects as folders)
- [x] Document belongs to one Project (one-to-many)
- [x] Tags remain many-to-many with Documents
- [x] Update UI to reflect simplified model

**Document CRUD** ✅
- [x] Create: Quick-add with + button
- [x] Read: Three-column layout with live preview
- [x] Update: Editable titles, real-time content editing
- [x] Delete: Confirmation dialog with swipe action
- [x] Duplicate: Context menu creates copy with "(Copy)" suffix
- [x] Archive: Hide without deleting, toggleable
- [x] Favorites: Star/unstar with visual indicator
- [x] Sorting: By date modified, date created, title, word count

**Project CRUD** ✅
- [x] Create: Quick-add or detailed edit sheet
- [x] Edit: Full sheet with name, description, icon, color picker
- [x] Delete: Confirmation dialog (documents stay intact)
- [x] Drag-drop: Drag documents onto projects to move
- [x] Context menu: Edit, Delete with confirmation
- [x] Platform-specific: Custom layout on Mac, Form on iOS

**Tag CRUD** ✅
- [x] Create: Quick-add or detailed edit sheet
- [x] Edit: Full sheet with name and color picker
- [x] Delete: Confirmation dialog (removed from all documents)
- [x] Apply: Context menu to toggle tags on documents
- [x] Visual badges: Colored circles in document list (up to 3 + count)
- [x] Platform-specific: Custom layout on Mac, Form on iOS

**UI Polish** ✅
- [x] Inline quick-add buttons (+ icon next to section headers)
- [x] Section headers for Documents, Projects, Tags
- [x] Colored circle icons for tags (not SF Symbols)
- [x] Tag color picker with live preview
- [x] Cross-platform consistency improvements

### v0.4.0 - Polish & Organization
**Goal:** Production-ready organizational features and app polish for 1.0 launch

**Organizational Features**
- [ ] Multi-select documents (Cmd/Ctrl-Click)
- [ ] Bulk operations: Delete, tag, move to project
- [ ] Bulk tag application from context menu

**First Launch Experience**
- [ ] Splash screen on first launch only
- [ ] Welcome message explaining three-column layout
- [ ] Sample document to demonstrate features
- [ ] User preference to skip in future

**Settings/Preferences Screen**
- [ ] Preview font size adjustment
- [ ] Editor font family and size selection
- [ ] Default export location (Mac only)
- [ ] CloudKit sync status display
- [ ] About section with version info and credits

**App Icon & Branding**
- [ ] Beautiful app icon (1024x1024 master)
- [ ] All required asset sizes (macOS, iOS, iPadOS)
- [ ] Launch screen images
- [ ] App Store marketing assets

**Quality Assurance**
- [ ] CloudKit sync verification across devices
- [ ] Cross-platform testing (Mac, iPad, iPhone)
- [ ] Performance testing with large document collections
- [ ] Memory leak detection and fixes

### v1.0.0 - App Store Launch
**Goal:** Public release on Mac App Store and iOS App Store

**Visual Polish**
- [ ] Final color scheme refinements for Dark and Light modes
- [ ] Consistent iconography throughout
- [ ] Polish animations and transitions
- [ ] Accessibility audit (VoiceOver, Dynamic Type)

**Marketing Materials**
- [ ] Convert README.md to beautiful one-page website
- [ ] Host marketing site on GitHub Pages
- [ ] App Store screenshots (all required sizes and devices)
- [ ] App Store preview video (30 seconds)
- [ ] App Store description and keywords

**Release Process**
- [ ] TestFlight beta testing (2 weeks minimum)
- [ ] Beta feedback incorporation
- [ ] App Store submission (Mac + iOS)
- [ ] App Store review process
- [ ] Public launch announcement

**Documentation**
- [ ] User guide on marketing website
- [ ] FAQ section
- [ ] Privacy policy
- [ ] Support contact information

### v2.0.0 - Advanced Features
**Goal:** MacDown feature parity with advanced editing capabilities

**Snippet System**
- [ ] Snippet CRUD operations (create, edit, delete)
- [ ] Snippet insertion UI (palette or quick-insert)
- [ ] Keyboard shortcuts for common snippets
- [ ] Snippet variables/placeholders with tab stops
- [ ] Pre-loaded snippet library (code blocks, tables, etc.)
- [ ] Snippet organization (categories, tags)

**Editor Intelligence**
- [ ] Auto-pairing: `[` → `[]`, `(` → `()`, `"` → `""`
- [ ] Smart list continuation (auto-adds bullets on return)
- [ ] Auto-indentation for nested lists
- [ ] Smart quotes (curly quotes option)
- [ ] Markdown-aware undo/redo
- [ ] Auto-completion for Markdown symbols

**LaTeX/Math Rendering**
- [ ] Integrate MathJax or KaTeX via CDN
- [ ] Support inline math `$...$`
- [ ] Support block math `$$...$$`
- [ ] Live preview of math expressions
- [ ] Math symbol auto-completion

**macOS System Extension**
- [ ] System-wide text capture extension
- [ ] Capture selected text from any app
- [ ] Automatically create document in Mac MD
- [ ] Auto-tag captured content with "For Review"
- [ ] Keyboard shortcut activation
- [ ] Background processing (no app launch required)

**Additional Enhancements**
- [ ] Custom themes and color schemes
- [ ] Export templates (custom CSS for HTML/PDF)
- [ ] Document templates
- [ ] Full-text search across all documents
- [ ] File system integration (import/export folders)
- [ ] Git integration (version control)
- [ ] Collaborative editing (iCloud shared documents)

### Future Considerations (v3.0+)
- [ ] Extensions/plugins API
- [ ] Multi-cursor editing
- [ ] Advanced table editing
- [ ] Diagram support (Mermaid, PlantUML)
- [ ] Bibliography management (BibTeX)
- [ ] Presentation mode (slides from Markdown)
- [ ] Web publishing integration
- [ ] AI writing assistance

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Special thanks to:
- **Stewart Lynch** for the Xcode Intelligence tutorial that sparked this project
- **Tzu-ping Chung** for creating the original MacDown
- **Paul Hudson** for endless Swift education and the SwiftAgents project
- **Antoine van der Lee** for detailed SwiftUI patterns and agent skills
- **The Swift Community** for being amazing and supportive
- **Anthropic** for Claude, which assisted in building this entire project

## 📧 Contact

Allen Hammock - [@brainvat](https://github.com/brainvat)

Project Link: [https://github.com/brainvat/markdown-editor](https://github.com/brainvat/markdown-editor)

---

**Note**: This is v0.3.0 with complete CRUD operations for Documents, Projects, and Tags. The app is fully functional for daily use. CloudKit sync and additional features are in development. Feedback and contributions are welcome!
