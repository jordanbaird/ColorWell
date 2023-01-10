//===----------------------------------------------------------------------===//
//
// CGRect+extension.swift
//
//===----------------------------------------------------------------------===//

import CoreGraphics

extension CGRect {
  /// The bottom left point of the rectangle.
  internal var bottomLeft: CGPoint {
    .init(x: minX, y: minY)
  }

  /// The top left point of the rectangle.
  internal var topLeft: CGPoint {
    .init(x: minX, y: maxY)
  }

  /// The top right point of the rectangle.
  internal var topRight: CGPoint {
    .init(x: maxX, y: maxY)
  }

  /// The bottom right point of the rectangle.
  internal var bottomRight: CGPoint {
    .init(x: maxX, y: minY)
  }

  /// Centers the current rectangle within the bounds of another rectangle.
  /// - Parameters otherRect: The rectangle to center the current rectangle in.
  internal func centered(in otherRect: Self) -> Self {
    var new = self
    new.origin.x = otherRect.midX - (new.width / 2)
    new.origin.y = otherRect.midY - (new.height / 2)
    return new
  }
}
