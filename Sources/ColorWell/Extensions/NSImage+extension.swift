//===----------------------------------------------------------------------===//
//
// NSImage+extension.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSImage {
  /// Creates an image by drawing a swatch in the given color and size.
  internal convenience init(color: NSColor, size: NSSize, radius: CGFloat = 0) {
    self.init(size: size, flipped: false) { bounds in
      NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius).addClip()
      color.drawSwatch(in: bounds)
      return true
    }
  }

  /// Draws the specified color in the given rectangle, with the given
  /// clipping path.
  ///
  /// > Explanation:
  /// This method differs from the `drawSwatch(in:)` method on `NSColor`
  /// in that it allows you to set a clipping path without affecting the
  /// border of the swatch.
  ///
  /// The swatch that is drawn using the `NSColor` method is drawn with
  /// a thin border around its edges, which is affected by the current
  /// graphics context's clipping path. This can yield undesirable
  /// results if we want to, for example, set our own border with a
  /// slightly different appearance (which we do).
  ///
  /// Basically, this method uses `NSColor`'s `drawSwatch(in:)` method
  /// to draw an image, then clips the image instead of the swatch path.
  internal static func drawSwatch(
    with color: NSColor,
    in rect: NSRect,
    clippingTo clippingPath: NSBezierPath? = nil
  ) {
    NSGraphicsContext.withTemporaryGraphicsState {
      clippingPath?.addClip()
      NSImage(color: color, size: rect.size).draw(in: rect)
    }
  }

  /// Returns a new image by clipping the current image to a circular shape
  /// and insetting its size by the given amount.
  internal func clippedToCircle(insetBy amount: CGFloat = 0) -> NSImage {
    let originalFrame = NSRect(origin: .zero, size: size)
    let insetDimension = min(size.width, size.height) - amount
    let insetFrame = NSRect(
      origin: .zero,
      size: .init(width: insetDimension, height: insetDimension)
    ).centered(in: originalFrame)
    return .init(size: insetFrame.size, flipped: false) { [self] bounds in
      let destFrame = NSRect(origin: .zero, size: bounds.size)
      NSBezierPath(ovalIn: destFrame).setClip()
      draw(in: destFrame, from: insetFrame, operation: .copy, fraction: 1)
      return true
    }
  }

  /// Returns new image that has been tinted to the given color.
  internal func tinted(to color: NSColor, amount: CGFloat) -> NSImage {
    guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      return self
    }
    let tintImage = NSImage(size: size, flipped: false) { bounds in
      guard let context = NSGraphicsContext.current?.cgContext else {
        return false
      }
      color.setFill()
      context.clip(to: bounds, mask: cgImage)
      context.fill(bounds)
      return true
    }
    return .init(size: size, flipped: false) { [self] bounds in
      draw(in: bounds)
      tintImage.draw(
        in: bounds,
        from: .init(origin: .zero, size: tintImage.size),
        operation: .sourceAtop,
        fraction: amount)
      return true
    }
  }
}
