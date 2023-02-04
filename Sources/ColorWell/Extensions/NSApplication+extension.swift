//===----------------------------------------------------------------------===//
//
// NSApplication+extension.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSApplication {
    /// A Boolean value that indicates whether the application's current
    /// effective appearance is a dark appearance.
    internal var effectiveAppearanceIsDarkAppearance: Bool {
        if #available(macOS 10.14, *) {
            return effectiveAppearance.isDarkAppearance
        } else {
            return false
        }
    }
}
