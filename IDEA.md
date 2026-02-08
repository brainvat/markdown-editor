Act as an expert Swift/SwiftUI engineer. Build "MacDown Pro," a 1:1 feature-parity clone of MacDown 3000, but modernized as a Universal App for macOS, iOS, and iPadOS.

### 1. CORE MACDOWN FEATURE PARITY
Replicate the following MacDown 3000 features exactly:
- **Rendering Engine:** Support for CommonMark, GitHub Flavored Markdown (GFM), and LaTeX (TeX-like math expressions) using MathJax/KaTeX.
- **Editor Intelligence:** 
    - Auto-completion for Markdown symbols (brackets, quotes, list bullets).
    - Syntax highlighting for the editor and fenced code blocks in preview.
    - Smart "Task List" support (toggling checkboxes).
- **Tooling:** Implement "Syntax Tools" including automatic link insertion and image embedding.
- **Live Preview:** Real-time dual-pane rendering (side-by-side on Mac/iPad, toggle-switch on iPhone).

### 2. ARCHITECTURE & ORGANIZATION (NEW)
- **Persistence:** Use SwiftData to manage the library. 
- **Data Models:** Create entities for `Document`, `Snippet`, and `Project`. 
- **Meta-Data:** Implement a 'Group' system (like Xcode folders) and a global 'Tag' system with a many-to-many relationship.
- **Syncing:** Enable the CloudKit entitlement to ensure all SwiftData entities sync seamlessly across iCloud-enabled devices.

### 3. ADVANCED EXPORT & UI
- **PDF Engine:** Implement a native PDF export function using PDFKit/UIGraphicsPDFRenderer that preserves styling.
- **HTML Export:** Include MacDown’s classic HTML export capability.
- **UI Layout:** Use a Three-Column Sidebar layout (Source List -> Document List -> Editor) that collapses gracefully on smaller screens.

### 4. TECHNICAL CONSTRAINTS
- Target: macOS 15+, iOS 18+.
- Language: Swift 6 (Strict concurrency).
- Interface: SwiftUI with Xcode Previews for every view.
- Dependencies: Use SPM for any Markdown parsing (e.g., 'Ink' or 'MarkdownUI') or Syntax Highlighting.

### INITIAL TASK:
1. Define the SwiftData Schema for Documents, Snippets, Projects, and Tags.
2. Outline the Folder Structure for the Xcode Project.
3. Start by building the 'MarkdownManager' class to handle parsing and PDF rendering.
