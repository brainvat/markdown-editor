# Mac MD - The Engineering Journey

## The Big Picture

Picture this: You're working on a long technical document, switching between plain text and a browser to see how it renders. Frustrating, right? That's the problem we're solving with **Mac MD** - a beautiful, distraction-free Markdown editor with a live preview sitting right next to your text.

**Mac MD** is a modern Universal App that works seamlessly on your Mac, iPad, and iPhone. Write on your Mac during the day, polish on your iPad on the couch, and make quick edits on your iPhone when inspiration strikes. Everything syncs through iCloud. It's like having one brain across all your devices.

Built with SwiftUI for buttery-smooth interfaces, SwiftData for elegant data management, and Swift 6 for rock-solid concurrency. Think of it as a modern take on classic Markdown editing, reimagined for 2026.

## Architecture Deep Dive

Think of Mac MD like a restaurant kitchen:

### The Data Layer (The Walk-In Cooler)
**SwiftData** is our walk-in cooler - everything gets stored here, perfectly organized. We have four main "shelves":

1. **Documents** - The main dishes. Each one is a Markdown file with content, metadata, and history.
2. **Snippets** - Pre-made ingredients. Reusable chunks of Markdown you use all the time.
3. **Projects** - Meal courses. Collections of related documents.
4. **Tags** - Flavor profiles. A document can have multiple tags, and tags can be on multiple documents (many-to-many relationship).

**CloudKit** is like having multiple restaurant locations that share inventory in real-time. Change something on your Mac? Your iPad knows about it almost instantly.

### The Service Layer (The Sous Chefs)
These are the workers behind the scenes:

- **MarkdownManager** - The head chef. Takes raw Markdown text and transforms it into beautiful HTML, handles LaTeX math expressions, and knows all the recipes (CommonMark, GFM).
- **ExportService** - The pastry chef. Takes that rendered content and packages it as PDF or HTML files.
- **SyntaxHighlighter** - The food stylist. Makes your code blocks look gorgeous with proper coloring.

### The UI Layer (The Dining Room)
This is what the customer sees:

- **Three-Column Layout** - Like a sushi bar where you can see everything: the menu (source list), today's specials (document list), and the chef preparing your order (editor + preview).
- **Responsive Design** - On a big Mac screen, you get the full sushi bar experience. On an iPad, maybe two columns. On an iPhone, it's more like a food truck window - one thing at a time, but still delicious.

### Why This Architecture?

We chose **SwiftData** because it's Apple's future. Core Data is the old guard - powerful but complex, like a French kitchen brigade. SwiftData is modern and Swift-native, like a efficient farm-to-table kitchen.

**SwiftUI** because building separate UIKit (iOS) and AppKit (macOS) interfaces would be like running two completely different restaurants. SwiftUI is one kitchen that adapts its dishes to any venue.

**Swift 6 strict concurrency** because data races are like cross-contamination in a kitchen - unacceptable. Strict concurrency is our HACCP plan, making sure every operation happens safely.

## The Codebase Map

Here's where everything lives (and why):

```
Markdown Editor/
├── App/                          # The restaurant's front door
│   └── Markdown_EditorApp.swift  # Main app entry point, sets up the "kitchen"
│
├── Models/                       # The ingredient specifications
│   ├── Document.swift            # The main dish
│   ├── Snippet.swift             # Pre-prep ingredients
│   ├── Project.swift             # Multi-course meals
│   ├── Tag.swift                 # Flavor tags
│   └── Group.swift               # Ingredient categories
│
├── Views/                        # The dining room and presentation
│   ├── Main/                     # The core dining experience
│   │   ├── ContentView.swift    # The main layout (currently basic)
│   │   ├── SidebarView.swift    # The menu
│   │   ├── DocumentListView.swift  # Today's specials
│   │   └── EditorView.swift     # Watch the chef work
│   │
│   ├── Preview/                  # The tasting experience
│   │   └── MarkdownPreviewView.swift  # Live rendering
│   │
│   └── Components/               # Reusable serving pieces
│       ├── MarkdownEditor.swift  # Custom text editor with smarts
│       └── SyntaxHighlightedText.swift  # Pretty code display
│
├── Services/                     # The kitchen staff
│   ├── MarkdownManager.swift    # Head chef (parsing, rendering)
│   ├── ExportService.swift      # Packaging (PDF/HTML)
│   └── SyntaxHighlighter.swift  # Food styling
│
├── Utilities/                    # Kitchen tools
│   └── Extensions/              # Custom utensils
│
└── Resources/                    # The restaurant's decor
    └── Assets.xcassets          # Colors, icons, images
```

**Navigation Rule**: If it manipulates data, it's a Service. If it displays data, it's a View. If it defines data structure, it's a Model. Simple as that.

## Tech Stack & Why

### SwiftData (Persistence Layer)
**Why**: Successor to Core Data. Less boilerplate, more Swift-native, better type safety. Using Core Data in 2026 would be like using a flip phone - sure, it works, but why?

**The Alternative**: Core Data. But have you seen the entity description files and NSManagedObject subclass generation? SwiftData's `@Model` macro does all that with one line.

### SwiftUI (UI Layer)
**Why**: Write once, run everywhere. The three-column layout code is IDENTICAL on macOS and iOS - SwiftUI just adapts it. Before SwiftUI, we'd need separate UIKit and AppKit code. That's double the work and double the bugs.

**The Trade-off**: SwiftUI is still maturing. Some advanced text editing features might be harder than with AppKit's NSTextView. But the cross-platform benefits crush the drawbacks.

### CloudKit (Sync Layer)
**Why**: It's free (up to generous limits), deeply integrated with Apple platforms, and respects user privacy. The alternative is rolling our own sync server or paying for Firebase.

**The Gotcha**: CloudKit syncing isn't instant. Changes can take seconds to minutes to propagate. This is fine for a document editor (not a chat app), but we need to design for it.

### MarkdownUI or Ink (Parsing)
**Why**: Don't reinvent the wheel. These libraries handle the gnarly details of Markdown parsing (did you know there are like 5 different "standards"?). We just feed in text, get out AST or HTML.

**Which One**: TBD. Ink is pure Swift, lightweight. MarkdownUI is a full SwiftUI rendering solution. We'll evaluate based on LaTeX support and performance.

## The Journey

### Day 1: Project Inception
**What We're Building**: A modern Markdown editor that works on Mac, iPad, and iPhone.

**Initial Decisions**:
- ✅ Swift 6 strict concurrency (future-proof)
- ✅ SwiftData + CloudKit (modern data stack)
- ✅ Universal App (all platforms, one codebase)
- ✅ Three-column NavigationSplitView (follows macOS conventions, adapts to iOS)

**Starting Point**: Fresh Xcode project with basic SwiftData template (Item.swift with timestamp).

**The Plan**:
1. Design data models (Document, Snippet, Project, Tag, Group)
2. Build MarkdownManager for parsing and rendering
3. Create the three-column UI shell
4. Implement live preview
5. Add editor intelligence (auto-completion, syntax highlighting)
6. Build export (PDF, HTML)
7. Polish and optimize

**Initial Questions**:
- Which Markdown library? (Ink vs MarkdownUI vs swift-markdown)
- LaTeX rendering approach? (MathJax via WKWebView vs native?)
- Syntax highlighting? (Splash vs Highlightr vs custom?)

These will be answered as we build.

## Engineer's Wisdom

### SwiftData Best Practices Demonstrated Here

1. **Relationships Go Both Ways**: If a Document has Tags, make sure Tag has Documents. SwiftData needs this for proper cascading deletes and queries.

2. **@Model vs @Observable**: Use `@Model` for persisted entities, `@Observable` for view models. They're not interchangeable.

3. **Query at the View Level**: Use `@Query` in views, not in view models. SwiftData is designed for views to query directly.

4. **ModelContext is Main-Thread Only**: Always do inserts/deletes on `@MainActor`. For background processing, create a new ModelContext on a background thread.

### Swift Concurrency Patterns

1. **@MainActor for UI**: Any class that updates views gets `@MainActor`. This prevents data races and ensures smooth updates.

2. **Actors for Isolated State**: Services like MarkdownManager that do heavy processing? Make them actors. This prevents multiple simultaneous renders from stepping on each other.

3. **Async/Await, Never Callbacks**: We're in 2026. Completion handlers are legacy code. Everything is async/await.

### Universal App Design

1. **Size Classes, Not Platform Checks**: Don't write `#if os(macOS)`. Use environment values like `horizontalSizeClass` instead. More flexible and testable.

2. **Toolbar vs NavigationBar**: Use `.toolbar` modifier - it adapts automatically. On macOS it's a toolbar, on iOS it's a nav bar.

3. **Test on All Devices**: SwiftUI's promise is "write once, run everywhere." The reality is "write once, debug everywhere." Test on Mac, iPad (all orientations), and iPhone regularly.

## If I Were Starting Over...

**Too Early to Say** - We just started! But I'll update this section as we learn what works and what doesn't.

## Lessons Learned

### Day 1 Progress: Core Architecture Complete ✅

**What We Built**:
1. ✅ Complete SwiftData schema (Document, Tag, Project, Snippet, Group)
2. ✅ Three-column NavigationSplitView layout
3. ✅ MarkdownManager with basic parsing and export capabilities
4. ✅ Live preview using WKWebView
5. ✅ CloudKit syncing enabled
6. ✅ Cross-platform support (macOS/iOS/iPadOS)

**Aha Moments**:

1. **@Observable vs ObservableObject** - Initially tried using `ObservableObject` with `@Published` for MarkdownManager, but that requires Combine. Swift's new `@Observable` macro (from Observation framework) is the modern, cleaner approach for Swift 6. Just add `@Observable` and your properties automatically become observable!

2. **Platform-Specific Views Done Right** - HSplitView and VSplitView are macOS-only. Instead of fighting it, we embraced `#if os(macOS)` with elegant fallbacks for iOS using HStack/VStack with proper frame management. This is where "write once, run everywhere" becomes "write once, adapt gracefully."

3. **SwiftData Relationships Are Bidirectional** - When you have a many-to-many relationship (Documents ↔ Tags), you MUST define BOTH sides with the `inverse` parameter. Otherwise SwiftData can't properly track changes and cascade deletes.

**Bug Battles**:

1. **The Missing Combine Import** - First build error: `ObservableObject` wasn't available because we didn't import Combine. But wait - we're using Swift 6! The fix? Switch to `@Observable` macro instead. This was a blessing in disguise - forced us to use modern Swift patterns.

2. **NSViewRepresentable vs UIViewRepresentable** - WebView needs different implementations for macOS (NSViewRepresentable) vs iOS (UIViewRepresentable). Used `#if canImport(AppKit)` to create platform-specific versions. The beauty? The parent view (MarkdownPreviewView) doesn't care - same interface, different implementations.

**Gotchas Avoided**:

1. **ModelContainer Configuration** - CloudKit syncing is literally one parameter: `cloudKitDatabase: .automatic`. But you need the CloudKit entitlement enabled first, or it silently fails. The entitlements file was already set up, so we just needed to add the parameter.

2. **@Bindable vs @Binding** - In EditorView, we use `@Bindable var document: Document` (not `@Binding`). Why? Because `Document` is a `@Model` class, and `@Bindable` is specifically designed for SwiftData models. It creates two-way bindings to model properties.

3. **WKWebView Background** - On macOS, WKWebView has a white background by default. Set `drawsBackground = false` to make it transparent. On iOS, use `isOpaque = false` and `backgroundColor = .clear`. Different APIs, same goal.

**Performance Wins**:

1. **Debounced Preview Updates** - Instead of re-rendering HTML on every keystroke, we use `Task.sleep(for: .milliseconds(300))` after the `onChange` trigger. This batches rapid changes and prevents preview flicker. The user types fast, we render smart.

2. **Computed Metrics** - Document word count and character count are computed on save (via `updateMetrics()`), not on every access. This keeps queries fast when sorting by word count.

3. **@Query at the View Level** - SwiftData's `@Query` automatically updates views when data changes. No need for manual refresh logic or NotificationCenter gymnastics. SwiftUI + SwiftData = automatic reactive UI.

**Engineering Wisdom Gained**:

1. **Swift 6 Strict Concurrency Is Your Friend** - The `@MainActor` attribute on MarkdownManager ensures all UI updates happen on the main thread. No more "Purple Warning: This application is modifying the autolayout engine from a background thread." Swift 6 catches this at compile time!

2. **NavigationSplitView Visibility** - Using `columnVisibility: $columnVisibility` state gives users control over which columns to show. On Mac, they can collapse sidebars. On iPad, it adapts to multitasking modes. On iPhone, it's automatically a navigation stack.

3. **ContentUnavailableView Is Gold** - When no document is selected, we show `ContentUnavailableView` instead of an empty pane. It's built-in, beautiful, and guides the user. Apple design patterns for the win!

**What's Next**:

Still pending:
- [ ] Integrate a proper Markdown parser (Ink or swift-markdown via SPM)
- [ ] Add syntax highlighting for code blocks
- [ ] Implement editor intelligence (auto-completion, snippets)
- [ ] LaTeX/Math rendering with MathJax
- [ ] Keyboard shortcuts (⌘N for new document, ⌘E for export, etc.)
- [ ] Search functionality
- [ ] Dark mode styling refinements

But here's the thing: **The app builds and runs!** We have a functional three-column layout with live preview, SwiftData persistence, and CloudKit syncing. From zero to MVP in one session. That's the power of SwiftUI and SwiftData.

---

*Last Updated: Day 1 - Core architecture complete, builds successfully*
