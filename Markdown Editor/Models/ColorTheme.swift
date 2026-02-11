//
//  ColorTheme.swift
//  Markdown Editor
//
//  Created by Claude on 2/10/26.
//

import SwiftUI

// MARK: - ColorTheme

/// A named color theme inspired by macOS Terminal profiles.
/// Each theme defines a background, foreground, and the 8 standard ANSI colors.
/// All themes share the same bright/bold ANSI variants.
struct ColorTheme: Identifiable, Equatable {
    let name: String
    
    // Background and text colors
    let background: Color
    let foreground: Color
    
    // Standard ANSI colors
    let ansiBlack: Color
    let ansiRed: Color
    let ansiGreen: Color
    let ansiYellow: Color
    let ansiBlue: Color
    let ansiMagenta: Color
    let ansiCyan: Color
    let ansiWhite: Color
    
    var id: String { name }
    
    // MARK: - Bright/Bold Variants (shared across all themes)
    
    static let brightBlack   = Color(hex: "#666666")
    static let brightRed     = Color(hex: "#E50000")
    static let brightGreen   = Color(hex: "#00D900")
    static let brightYellow  = Color(hex: "#E5E500")
    static let brightBlue    = Color(hex: "#0000FF")
    static let brightMagenta = Color(hex: "#E500E5")
    static let brightCyan    = Color(hex: "#00E5E5")
    static let brightWhite   = Color(hex: "#E5E5E5")
    
    // MARK: - Shared Standard ANSI Colors
    
    /// Standard ANSI colors shared by most Terminal profiles
    private static func standardANSI(red: String = "#990000") -> (Color, Color, Color, Color, Color, Color, Color, Color) {
        (
            Color(hex: "#000000"),  // black
            Color(hex: red),        // red (overridable)
            Color(hex: "#00A600"),  // green
            Color(hex: "#999900"),  // yellow
            Color(hex: "#0000B2"),  // blue
            Color(hex: "#B200B2"),  // magenta
            Color(hex: "#00A6B2"),  // cyan
            Color(hex: "#BFBFBF")   // white
        )
    }
}

// MARK: - Built-in Presets

extension ColorTheme {
    
    /// All built-in Terminal-inspired presets, in display order
    static let allPresets: [ColorTheme] = [
        .basic, .grass, .homebrew, .manPage, .novel,
        .ocean, .pro, .redSands, .silverAerogel, .solidColors
    ]
    
    /// Looks up a preset by name, falling back to .basic
    static func preset(named name: String) -> ColorTheme {
        allPresets.first { $0.name == name } ?? .basic
    }
    
    // MARK: Presets
    
    static let basic: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Basic",
            background: Color(hex: "#FFFFFF"),
            foreground: Color(hex: "#000000"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let grass: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Grass",
            background: Color(hex: "#13773D"),
            foreground: Color(hex: "#FFFFFF"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let homebrew: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Homebrew",
            background: Color(hex: "#000000"),
            foreground: Color(hex: "#00FF00"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let manPage: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Man Page",
            background: Color(hex: "#FEF49C"),
            foreground: Color(hex: "#000000"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let novel: ColorTheme = {
        // Novel uses a slightly different red (#CC0000 instead of #990000)
        let (black, _, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Novel",
            background: Color(hex: "#DFDBC3"),
            foreground: Color(hex: "#3B2322"),
            ansiBlack: black, ansiRed: Color(hex: "#CC0000"), ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let ocean: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Ocean",
            background: Color(hex: "#224FBC"),
            foreground: Color(hex: "#FFFFFF"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let pro: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Pro",
            background: Color(hex: "#000000"),
            foreground: Color(hex: "#F2F2F2"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let redSands: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Red Sands",
            background: Color(hex: "#7A251E"),
            foreground: Color(hex: "#D7C9A1"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let silverAerogel: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Silver Aerogel",
            background: Color(hex: "#ADB2B7"),
            foreground: Color(hex: "#000000"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
    
    static let solidColors: ColorTheme = {
        let (black, red, green, yellow, blue, magenta, cyan, white) = standardANSI()
        return ColorTheme(
            name: "Solid Colors",
            background: Color(hex: "#000000"),
            foreground: Color(hex: "#FFFFFF"),
            ansiBlack: black, ansiRed: red, ansiGreen: green, ansiYellow: yellow,
            ansiBlue: blue, ansiMagenta: magenta, ansiCyan: cyan, ansiWhite: white
        )
    }()
}

// Color(hex:) is defined in ColorExtensions.swift
