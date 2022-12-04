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

// MARK: - ConstructablePath

protocol ConstructablePath: ConstructablePathConvertible {
  associatedtype Convertible: ConstructablePathConvertible
  init()
  var convertiblePath: Convertible { get }
  mutating func apply(_ component: PathConstructor.Component)
}

extension ConstructablePath where Convertible == Self {
  var convertiblePath: Self { self }
}

extension ConstructablePath {
  static func fromComponents(_ components: [PathConstructor.Component]) -> Self {
    var path = Self()
    for component in components {
      path.apply(component)
    }
    return path
  }
}

extension NSBezierPath: ConstructablePath {
  func apply(_ component: PathConstructor.Component) {
    switch component {
    case .close:
      close()
    case .move(let point):
      move(to: point)
    case .line(let point):
      line(to: point)
    case .curve(let point, let c1, let c2):
      curve(to: point, controlPoint1: c1, controlPoint2: c2)
    }
  }
}

extension CGMutablePath: ConstructablePath {
  var convertiblePath: CGPath { self }

  func apply(_ component: PathConstructor.Component) {
    switch component {
    case .close:
      closeSubpath()
    case .move(let point):
      move(to: point)
    case .line(let point):
      addLine(to: point)
    case .curve(let point, let c1, let c2):
      addCurve(to: point, control1: c1, control2: c2)
    }
  }
}

// MARK: - ConstructablePathConvertible

protocol ConstructablePathConvertible {
  associatedtype Constructable: ConstructablePath
  typealias Constructed = Constructable.Convertible
  var constructablePath: Constructable { get }
  static func fromComponents(_ components: [PathConstructor.Component]) -> Constructed
}

extension ConstructablePathConvertible where Self: ConstructablePath {
  var constructablePath: Self { self }
}

extension ConstructablePathConvertible {
  static func fromComponents(_ components: [PathConstructor.Component]) -> Constructed {
    Constructable.fromComponents(components).convertiblePath
  }
}

extension CGPath: ConstructablePathConvertible {
  var constructablePath: CGMutablePath {
    let path = CGMutablePath()
    path.addPath(self)
    return path
  }
}

// MARK: - PathConstructor

enum PathConstructor { }

// MARK: PathConstructor Component
extension PathConstructor {
  enum Component {
    case close
    case move(to: CGPoint)
    case line(to: CGPoint)
    case curve(to: CGPoint, c1: CGPoint, c2: CGPoint)
  }
}

// MARK: Default Constructors
extension PathConstructor {
  static func colorWellPath<P: ConstructablePathConvertible>(
    ofType type: P.Type = P.self,
    for dirtyRect: CGRect,
    flatteningCorners corners: [KeyPath<CGRect, CGPoint>] = []
  ) -> P where P.Constructable.Convertible == P {
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

    return .fromComponents(components)
  }
}

#if canImport(SwiftUI)

// MARK: - ViewConstructor

@available(macOS 10.15, *)
struct ViewConstructor<Content: View>: View {
  private let content: Content

  var body: some View {
    content
  }

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  init(content: @autoclosure () -> Content) {
    self.init(content: content)
  }

  func with<Modified: View>(@ViewBuilder _ block: (Content) -> Modified) -> ViewConstructor<Modified> {
    .init(content: block(content))
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

  init<Content: View>(base: ViewConstructor<Content>) {
    self.base = base
  }

  init<Content: View>(@ViewBuilder content: () -> Content) {
    self.init(base: .init(content: content))
  }

  init<Content: View>(content: @autoclosure () -> Content) {
    self.init(content: content)
  }
}

// MARK: - CustomCocoaConvertible

protocol CustomCocoaConvertible<CocoaType, Converted> {
  associatedtype CocoaType: NSObject
  associatedtype Converted: CustomCocoaConvertible = Self
  static func converted(from source: CocoaType) -> Converted
}

@available(macOS 10.15, *)
extension Color: CustomCocoaConvertible {
  static func converted(from source: NSColor) -> Self {
    .init(source)
  }
}

extension CGColor: CustomCocoaConvertible {
  static func converted(from source: NSColor) -> CGColor {
    source.cgColor
  }
}

// MARK: - StringProtocol Label

@available(macOS 10.15, *)
extension StringProtocol {
  var label: Text {
    .init(self)
  }
}

// MARK: - LocalizedStringKey Label

@available(macOS 10.15, *)
extension LocalizedStringKey {
  var label: Text {
    .init(self)
  }
}
#endif
