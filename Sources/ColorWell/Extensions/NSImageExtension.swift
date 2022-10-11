//===----------------------------------------------------------------------===//
//
// NSImageExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSImage {
  /// Creates an image by drawing a swatch in the given color and size.
  convenience init(color: NSColor, size: NSSize) {
    self.init(size: size)
    lockFocus()
    color.drawSwatch(in: .init(origin: .zero, size: size))
    unlockFocus()
  }
  
  /// Returns a new image by clipping the current image to the shape of
  /// an oval, insetting the current image's size by the given amount.
  func clippedToOval(insetBy amount: CGFloat = 0) -> NSImage {
    let originalFrame = NSRect(origin: .zero, size: size)
    let insetFrame = NSRect(
      origin: .zero,
      size: .init(
        width: size.width - amount,
        height: size.height - amount)
    ).centered(in: originalFrame)
    
    let image = NSImage(size: insetFrame.size)
    image.lockFocus()
    
    let destFrame = NSRect(origin: .zero, size: image.size)
    NSBezierPath(ovalIn: destFrame).addClip()
    draw(in: destFrame, from: insetFrame, operation: .copy, fraction: 1)
    
    image.unlockFocus()
    return image
  }
}
