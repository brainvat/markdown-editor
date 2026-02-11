//
//  ThemePickerView.swift
//  Markdown Editor
//
//  Created by Claude on 2/10/26.
//

import SwiftUI

/// A scrollable grid of color theme swatches for selecting an editor theme.
struct ThemePickerView: View {
    @Binding var selectedThemeName: String
    
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(ColorTheme.allPresets) { theme in
                ThemeSwatchView(
                    theme: theme,
                    isSelected: theme.name == selectedThemeName
                ) {
                    selectedThemeName = theme.name
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Theme Swatch

private struct ThemeSwatchView: View {
    let theme: ColorTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                // Color preview rectangle
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.background)
                    .frame(height: 48)
                    .overlay {
                        // Sample text to show foreground/background contrast
                        Text("Aa")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(theme.foreground)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        // Show a few ANSI color dots to hint at the palette
                        HStack(spacing: 2) {
                            Circle().fill(theme.ansiRed).frame(width: 5, height: 5)
                            Circle().fill(theme.ansiGreen).frame(width: 5, height: 5)
                            Circle().fill(theme.ansiBlue).frame(width: 5, height: 5)
                        }
                        .padding(4)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isSelected ? Color.accentColor : Color.secondary.opacity(0.3),
                                lineWidth: isSelected ? 2.5 : 1
                            )
                    )
                
                // Theme name label
                Text(theme.name)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name) theme\(isSelected ? ", selected" : "")")
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selected = "Basic"
    ThemePickerView(selectedThemeName: $selected)
        .padding()
        .frame(width: 400)
}
