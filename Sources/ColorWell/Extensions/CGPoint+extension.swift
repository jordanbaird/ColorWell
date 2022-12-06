//===----------------------------------------------------------------------===//
//
// CGPointExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import CoreGraphics

extension CGPoint {
  /// Returns a new point resulting from a translation of the current point.
  internal func translating(x: CGFloat = 0, y: CGFloat = 0) -> Self {
    applying(.init(translationX: x, y: y))
  }
}
