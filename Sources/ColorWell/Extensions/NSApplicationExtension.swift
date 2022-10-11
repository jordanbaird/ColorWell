//===----------------------------------------------------------------------===//
//
// NSApplicationExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSApplication {
  /// A Boolean value that indicates whether the application's current
  /// effective appearance is a dark appearance.
  var effectiveAppearanceIsDarkAppearance: Bool {
    if #available(macOS 10.14, *) {
      return effectiveAppearance.isDarkAppearance
    } else {
      return false
    }
  }
}
