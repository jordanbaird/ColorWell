//===----------------------------------------------------------------------===//
//
// NSAppearance+extension.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSAppearance {
    /// The dark appearance names supported by the system.
    private static let builtinDarkNames: Set<Name> = {
        var names: Set<Name> = [.vibrantDark]
        if #available(macOS 10.14, *) {
            names.insert(.darkAqua)
            names.insert(.accessibilityHighContrastDarkAqua)
            names.insert(.accessibilityHighContrastVibrantDark)
        }
        return names
    }()

    /// Whether the current appearance's name indicates a dark appearance.
    private var nameIndicatesDarkAppearance: Bool {
        name.rawValue.lowercased().contains("dark")
    }

    /// Whether the current appearance is a dark appearance.
    internal var isDarkAppearance: Bool {
        Self.builtinDarkNames.contains(name) || nameIndicatesDarkAppearance
    }
}
