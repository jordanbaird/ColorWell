//===----------------------------------------------------------------------===//
//
// NSColorPanelExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSColorPanel {
  private static var storage = [NSColorPanel: Set<ColorWell>]()

  /// The color wells that are currently active and share this color panel.
  var activeColorWells: Set<ColorWell> {
    get { Self.storage[self] ?? [] }
    set {
      if newValue.isEmpty {
        Self.storage.removeValue(forKey: self)
      } else {
        Self.storage[self] = newValue
      }
    }
  }
}
