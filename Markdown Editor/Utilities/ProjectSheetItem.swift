//
//  ProjectSheetItem.swift
//  Markdown Editor
//
//  Wrapper to make project editing identifiable for .sheet(item:)
//

import Foundation

/// Wrapper to make project editing identifiable for .sheet(item:)
///
/// **Purpose**: Fixes SwiftUI sheet initialization timing issues
/// **Problem**: Using `.sheet(isPresented:)` with optional state can cause the sheet
///              to initialize before the optional value is set, resulting in nil values
/// **Solution**: Use `.sheet(item:)` with this wrapper, ensuring the sheet only
///              initializes when the item is non-nil and properly set
///
/// **Usage**:
/// ```swift
/// @State private var projectSheetItem: ProjectSheetItem?
///
/// .sheet(item: $projectSheetItem) { sheetItem in
///     ProjectEditSheet(project: sheetItem.project)
/// }
///
/// // To show sheet for editing existing project:
/// projectSheetItem = ProjectSheetItem(project: existingProject)
///
/// // To show sheet for creating new project:
/// projectSheetItem = ProjectSheetItem(project: nil)
/// ```
struct ProjectSheetItem: Identifiable {
    let id = UUID()
    let project: Project?
}
