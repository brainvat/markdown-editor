# Mac MD

<img src="mac_md.png" alt="Mac MD Logo" width="200"/>

A modern Markdown editor for macOS, iOS, and iPadOS built with SwiftUI and SwiftData.

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20iPadOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### Core Functionality
- 📝 **Live Markdown Preview** - Real-time rendering with GitHub Flavored Markdown support
- 🎨 **Three-Column Layout** - Sidebar, document list, and editor with adjustable preview
- 📱 **Universal App** - Native experience on Mac, iPad, and iPhone
- 🌓 **Dark Mode** - Beautiful styling that adapts to system appearance
- ☁️ **iCloud Sync** - Available with **Mac MD Premium** subscription

### Document Organization
- 📂 **Projects** - Group related documents together with icons and colors
- 🏷️ **Tags** - Flexible many-to-many tagging system with colored badges
- ⭐ **Favorites** - Quick access to important documents
- 🕐 **Recents** - Smart collection of recently accessed documents
- 📦 **Archived** - Hide completed documents without deleting

### Markdown Support
- ✅ **CommonMark** - Full standard Markdown support via swift-markdown
- ✅ **GitHub Flavored Markdown** - Tables, task lists, strikethrough, and more

### Export & Sharing
- 📄 **PDF Export** - Native PDF generation (Mac ✅, iOS ✅)
- 🌐 **HTML Export** - Standalone HTML files with embedded CSS (Mac ✅, iOS ❌)
- 📝 **Markdown Export** - Export as .md files (Mac ✅, iOS ❌)
- 📊 **Document Stats** - Word count, character count, last modified

> **Note:** iOS HTML and Markdown exports are blocked by a confirmed SwiftUI framework bug where `.fileExporter()` silently fails for certain `FileDocument` types.

### Internationalization
- 🌍 **38 Languages** - Full localization across all platforms

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

## 🏗️ Architecture

Mac MD follows modern Swift and SwiftUI best practices:

### Data Layer
- **SwiftData** for local persistence with `@Model` macro
- **CloudKit** integration for iCloud syncing (Mac MD Premium only)
- Three core entities: `Document`, `Tag`, and `Project`
- Bidirectional relationships with proper cascade rules

### UI Layer
- **SwiftUI** exclusively - no UIKit/AppKit representables (except WebView)
- **NavigationSplitView** for adaptive three-column layout
- **@Observable** macro for reactive state management
- Platform-specific adaptations where needed

### Service Layer
- **MarkdownManager** - Centralized Markdown parsing and rendering (@MainActor)
- **SubscriptionManager** - StoreKit 2 subscription management
- Async/await throughout (Swift 6 strict concurrency)

### Project Structure
```
Markdown Editor/
├── Models/              # SwiftData eßntities
│   ├── Document.swift
│   ├── Tag.swift
│   └── Project.swift
├── Views/
│   ├── Main/           # Three-column layout
│   ├── Preview/        # WebKit-based renderer
│   ├── Onboarding/     # Welcome splash screen
│   └── Components/     # Reusable sheets and dialogs
├── Services/           # Business logic
├── Utilities/          # Extensions and helpers
└── Localizable.xcstrings  # 38-language localization
```

## 🎓 Inspiration & Credits

### Primary Inspirations

**[MacDown](https://macdown.app)** by [Tzu-ping Chung](https://github.com/uranusjr)
- The original MacDown is a beloved open-source Markdown editor for macOS
- Mac MD was inspired by MacDown's elegant approach to Markdown editing
- Mac MD brings a similar experience to iOS/iPadOS with modern SwiftUI
- If you're on macOS only, definitely check out the original MacDown!

**[Xcode 26.3 Intelligence Tutorial](https://www.youtube.com/watch?v=QdpaI_j0FRU)** by [Stewart Lynch](https://www.youtube.com/@StewartLynch)
- Incredible tutorial on using Xcode Intelligence (Claude integration) for SwiftUI development
- [Stewart's YouTube Channel](https://www.youtube.com/@StewartLynch) is an amazing resource

### AI Agent Development

**[SwiftAgents](https://github.com/twostraws/SwiftAgents)** by [Paul Hudson](https://github.com/twostraws)

**[SwiftUI Agent Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill)** by [Antoine van der Lee](https://github.com/AvdLee)

### Development Tools

- **[Claude](https://claude.ai)** by Anthropic - AI pair programming assistant
- **SwiftUI** & **SwiftData** by Apple - Modern app development framework
- **Xcode** - The amazing IDE that makes iOS development possible

## 📖 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Project memory, architecture decisions, and conventions
- **[Journal.md](Journal.md)** - Engineering journey with lessons learned and best practices

## 🗺️ Roadmap

### v1.0.0 - App Store Launch ✅
- [x] SwiftData schema (Document, Tag, Project)
- [x] Three-column NavigationSplitView layout
- [x] Live Markdown preview (CommonMark + GFM via swift-markdown)
- [x] Document CRUD with archive, favorites, sorting
- [x] Project and Tag CRUD with color pickers
- [x] Multi-select with bulk delete, move, and tag operations
- [x] PDF export (Mac + iOS), HTML/Markdown export (Mac only)
- [x] Settings: editor font, preview font, 10 color themes
- [x] Welcome splash screen on first launch
- [x] Mac MD Premium subscription (iCloud Sync via StoreKit 2)
- [x] iCloud sync via CloudKit (Premium only)
- [x] 38-language localization
- [x] Marketing website (GitHub Pages)

### Future Ideas
- Beta system with variables and tab stops
- Editor intelligence (auto-pairing, smart list continuation)
- LaTeX/Math rendering (MathJax or KaTeX)
- macOS system extension for capturing text from any app
- Full-text search across all documents
- Custom export templates (CSS for HTML/PDF)
- Document templates
- Git integration
- Collaborative editing via iCloud shared documents
- Diagram support (Mermaid, PlantUML)

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
