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
- 📂 **Projects** - Group related documents together
- 🏷️ **Tags** - Flexible many-to-many tagging system with colors
- 📁 **Groups** - Nested folder organization (Xcode-style)
- ⭐ **Favorites** - Quick access to important documents
- 🕐 **Recents** - Smart collection of recently accessed documents

### Markdown Support
- ✅ **CommonMark** - Full standard Markdown support
- 🔧 **GitHub Flavored Markdown** - Tables, task lists, and more
- 🧮 **LaTeX/Math** - Mathematical expressions via MathJax
- 💻 **Syntax Highlighting** - Beautiful code blocks (coming soon)
- 📋 **Smart Lists** - Auto-continuation and task list toggling

### Export & Sharing
- 📄 **PDF Export** - Native PDF generation with styling preservation
- 🌐 **HTML Export** - Standalone HTML files with embedded CSS
- 📊 **Document Stats** - Word count, character count, last modified

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
- **CloudKit** integration for automatic iCloud syncing
- Five core entities: `Document`, `Tag`, `Project`, `Snippet`, `Group`
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
│   ├── Snippet.swift
│   └── Group.swift
├── Views/
│   ├── Main/           # Three-column layout
│   └── Preview/        # WebKit-based renderer
├── Services/           # Business logic
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

### v0.1.0-alpha (Current) ✅
- [x] SwiftData schema with 5 models
- [x] Three-column layout
- [x] Basic Markdown rendering
- [x] Live preview
- [x] CloudKit syncing
- [x] PDF/HTML export

### v0.2.0 (Next)
- [ ] Integrate proper Markdown parser via SPM
- [ ] Syntax highlighting for code blocks
- [ ] Keyboard shortcuts
- [ ] Document search
- [ ] Performance optimizations

### v0.3.0
- [ ] Editor intelligence (auto-completion)
- [ ] Snippet insertion
- [ ] Custom themes
- [ ] Advanced LaTeX rendering

### v1.0.0
- [ ] Feature parity with MacDown 3000
- [ ] Comprehensive test coverage
- [ ] Performance tuning
- [ ] App Store release

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

**Note**: This is an alpha release (v0.1.0-alpha). The core architecture is complete and functional, but some features are still in development. Feedback and contributions are welcome!
