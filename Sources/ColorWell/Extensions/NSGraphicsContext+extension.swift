//===----------------------------------------------------------------------===//
//
// NSGraphicsContext+extension.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSGraphicsContext {
  /// Executes a block of code on the current graphics context, restoring
  /// the graphics state after the block returns.
  internal static func withTemporaryGraphicsState<T>(
    do block: (NSGraphicsContext?) throws -> T
  ) rethrows -> T {
    let context = current
    context?.saveGraphicsState()
    defer {
      context?.restoreGraphicsState()
    }
    return try block(context)
  }

  /// Executes a block of code on the current graphics context, restoring
  /// the graphics state after the block returns.
  internal static func withTemporaryGraphicsState<T>(
    do block: () throws -> T
  ) rethrows -> T {
    try withTemporaryGraphicsState { _ in
      try block()
    }
  }
}
