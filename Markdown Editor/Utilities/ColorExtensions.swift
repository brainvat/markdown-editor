//
//  ColorExtensions.swift
//  Markdown Editor
//
//  Cross-platform color serialization utilities for SwiftData/CoreData
//

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Color Serialization Pattern for SwiftData/CoreData

/// Extension for converting SwiftUI Color to/from hex strings for SwiftData storage
///
/// **Pattern**: Store colors as hex strings (e.g., "#007AFF") in SwiftData models
/// **Rationale**: Hex strings are machine-independent, JSON-compatible, and human-readable
///
/// **Usage in Models**:
/// ```swift
/// @Model
/// class Project {
///     var colorHex: String = "#007AFF"  // Store as hex string
/// }
/// ```
///
/// **Usage in Views**:
/// ```swift
/// // Convert hex → Color for display
/// Color(hex: project.colorHex)
///
/// // Convert Color → hex for storage
/// ColorPicker(selection: Binding(
///     get: { Color(hex: colorHex) },
///     set: { colorHex = $0.toHex() }
/// ))
/// ```
extension Color {
    
    // MARK: - Hex String → Color
    
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (supports "#RGB", "#RRGGBB", "RGB", "RRGGBB")
    /// - Returns: Color instance, defaults to black if parsing fails
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0) // Default to black for invalid input
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
    
    // MARK: - Color → Hex String
    
    /// Convert Color to hex string for storage
    /// - Returns: Hex string in format "#RRGGBB"
    func toHex() -> String {
        // Convert SwiftUI Color to platform-native color type
        #if os(macOS)
        let nativeColor = NSColor(self)
        #else
        let nativeColor = UIColor(self)
        #endif
        
        // Extract RGB components from CGColor
        guard let components = nativeColor.cgColor.components,
              components.count >= 3 else {
            return "#000000" // Default to black if conversion fails
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        // Convert to 0-255 range and format as hex
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}

// MARK: - Additional Color Utilities

extension Color {
    /// Common colors as hex strings for SwiftData storage
    struct HexColors {
        static let blue = "#007AFF"
        static let green = "#34C759"
        static let indigo = "#5856D6"
        static let orange = "#FF9500"
        static let pink = "#FF2D55"
        static let purple = "#AF52DE"
        static let red = "#FF3B30"
        static let teal = "#5AC8FA"
        static let yellow = "#FFCC00"
        static let gray = "#8E8E93"
    }
}

// MARK: - Platform-Native Color Helpers (Optional)

#if os(macOS)
extension NSColor {
    /// Convert NSColor to hex string
    var hexString: String {
        Color(self).toHex()
    }
}
#else
extension UIColor {
    /// Convert UIColor to hex string
    var hexString: String {
        Color(self).toHex()
    }
}
#endif
