//===----------------------------------------------------------------------===//
//
// NSViewExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSView {
  /// Returns the view's frame, converted to the coordinate system of its window.
  internal var frameConvertedToWindow: NSRect {
    superview?.convert(frame, to: nil) ?? frame
  }
}
