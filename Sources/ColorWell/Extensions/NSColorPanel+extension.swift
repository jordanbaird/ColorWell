//===----------------------------------------------------------------------===//
//
// NSColorPanelExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSColorPanel {
  private static let storage = Storage(Set<ColorWell>.self)

  /// The color wells that are currently active and share this color panel.
  internal var activeColorWells: Set<ColorWell> {
    get { Self.storage[self] ?? [] }
    set {
      if newValue.isEmpty {
        Self.storage[self] = nil
      } else {
        Self.storage[self] = newValue
      }
    }
  }
}
