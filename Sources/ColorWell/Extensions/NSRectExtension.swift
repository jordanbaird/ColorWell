//===----------------------------------------------------------------------===//
//
// NSRectExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSRect {
  /// The bottom left point of the rectangle.
  var bottomLeft: NSPoint {
    .init(x: minX, y: minY)
  }

  /// The top left point of the rectangle.
  var topLeft: NSPoint {
    .init(x: minX, y: maxY)
  }

  /// The top right point of the rectangle.
  var topRight: NSPoint {
    .init(x: maxX, y: maxY)
  }

  /// The bottom right point of the rectangle.
  var bottomRight: NSPoint {
    .init(x: maxX, y: minY)
  }

  /// Centers the current rectangle within the bounds of another rectangle.
  /// - Parameters otherRect: The rectangle to center the current rectangle in.
  func centered(in otherRect: Self) -> Self {
    var copy = self
    copy.origin = .init(
      x: otherRect.midX - width / 2,
      y: otherRect.midY - height / 2)
    return copy
  }
}
