//===----------------------------------------------------------------------===//
//
// Utilities.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Path

struct Path {
  let components: [Component]

  var nsBezierPath: NSBezierPath {
    let path = NSBezierPath()
    for component in components {
      component.add(to: path)
    }
    return path
  }

  var cgMutablePath: CGMutablePath {
    let path = CGMutablePath()
    for component in components {
      component.add(to: path)
    }
    return path
  }
}

extension Path {
  enum Component {
    case close
    case move(to: CGPoint)
    case line(to: CGPoint)
    case curve(to: CGPoint, c1: CGPoint, c2: CGPoint)

    fileprivate func add(to path: NSBezierPath) {
      switch self {
      case .close:
        path.close()
      case .move(to: let point):
        path.move(to: point)
      case .line(to: let point):
        path.line(to: point)
      case .curve(to: let point, c1: let c1, c2: let c2):
        path.curve(to: point, controlPoint1: c1, controlPoint2: c2)
      }
    }

    fileprivate func add(to path: CGMutablePath) {
      switch self {
      case .close:
        path.closeSubpath()
      case .move(to: let point):
        path.move(to: point)
      case .line(to: let point):
        path.addLine(to: point)
      case .curve(to: let point, c1: let c1, c2: let c2):
        path.addCurve(to: point, control1: c1, control2: c2)
      }
    }
  }
}

extension Path {
  static func colorWellPath(
    for dirtyRect: CGRect,
    flatteningCorners corners: [KeyPath<CGRect, CGPoint>] = []
  ) -> Self {
    let radius = ColorWell.cornerRadius

    let insetRect = dirtyRect.insetBy(
      dx: -ColorWell.lineWidth / 2,
      dy: -ColorWell.lineWidth / 2)

    var components = [Component]()

    if corners.contains(\.topLeft) {
      components.append(.move(to: dirtyRect.topLeft))
    } else {
      components += [
        .move(
          to: dirtyRect.topLeft.applying(
            .init(
              translationX: 0,
              y: -radius))),
        .curve(
          to: dirtyRect.topLeft.applying(
            .init(
              translationX: radius,
              y: 0)),
          c1: insetRect.topLeft,
          c2: insetRect.topLeft),
      ]
    }

    if corners.contains(\.topRight) {
      components.append(.line(to: dirtyRect.topRight))
    } else {
      components += [
        .line(
          to: dirtyRect.topRight.applying(
            .init(
              translationX: -radius,
              y: 0))),
        .curve(
          to: dirtyRect.topRight.applying(
            .init(
              translationX: 0,
              y: -radius)),
          c1: insetRect.topRight,
          c2: insetRect.topRight),
      ]
    }

    if corners.contains(\.bottomRight) {
      components.append(.line(to: dirtyRect.bottomRight))
    } else {
      components += [
        .line(
          to: dirtyRect.bottomRight.applying(
            .init(
              translationX: 0,
              y: radius))),
        .curve(
          to: dirtyRect.bottomRight.applying(
            .init(
              translationX: -radius,
              y: 0)),
          c1: insetRect.bottomRight,
          c2: insetRect.bottomRight),
      ]
    }

    if corners.contains(\.bottomLeft) {
      components.append(.line(to: dirtyRect.bottomLeft))
    } else {
      components += [
        .line(
          to: dirtyRect.bottomLeft.applying(
            .init(
              translationX: radius,
              y: 0))),
        .curve(
          to: dirtyRect.bottomLeft.applying(
            .init(
              translationX: 0,
              y: radius)),
          c1: insetRect.bottomLeft,
          c2: insetRect.bottomLeft),
      ]
    }

    components.append(.close)

    return .init(components: components)
  }
}

#if canImport(SwiftUI)

// MARK: - ViewConstructor

@available(macOS 10.15, *)
struct ViewConstructor<Content: View>: View {
  private let content: () -> Content

  var body: some View {
    content()
  }

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  func with<Modified: View>(@ViewBuilder _ block: (Content) -> Modified) -> ViewConstructor<Modified> {
    let newContent = block(content())
    return ViewConstructor<Modified> {
      newContent
    }
  }

  func erased() -> AnyViewConstructor {
    .init(base: self)
  }
}

// MARK: - AnyViewConstructor

@available(macOS 10.15, *)
struct AnyViewConstructor: View {
  let base: any View

  var body: some View {
    AnyView(base)
  }

  init<V: View>(base: ViewConstructor<V>) {
    self.base = base
  }
}
#endif
