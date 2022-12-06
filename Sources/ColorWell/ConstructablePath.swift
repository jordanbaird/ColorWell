//===----------------------------------------------------------------------===//
//
// ConstructablePath.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

// MARK: - Corner

internal typealias Corner = KeyPath<CGRect, CGPoint>
extension Corner {
  internal static let topLeft: Corner = \.topLeft
  internal static let topRight: Corner = \.topRight
  internal static let bottomLeft: Corner = \.bottomLeft
  internal static let bottomRight: Corner = \.bottomRight
  internal static let invalid: Corner = \.invalidPoint

  /// The valid corners that can be used during path construction.
  ///
  /// - Important: The order of elements in the array is the order that is
  ///   used during color well path construction, starting at the top left
  ///   and moving clockwise around the color well's border.
  internal static let all: [Corner] = [.topLeft, .topRight, .bottomRight, .bottomLeft]
}

extension Corner {
  internal var opposite: Corner {
    switch self {
    case .topLeft:
      return .bottomRight
    case .topRight:
      return .bottomLeft
    case .bottomLeft:
      return .topRight
    case .bottomRight:
      return .topLeft
    default:
      assertionInvalid()
      return .invalid
    }
  }

  internal func assertionInvalid() {
    assertionFailure("Valid corners are topLeft, topRight, bottomLeft, and bottomRight")
  }
}

struct Side {
  let corners: [Corner]

  init(_ corners: [Corner]) {
    self.corners = corners
  }
}

extension Side {
  static let top = Self([.topLeft, .topRight])
  static let bottom = Self([.bottomLeft, .bottomRight])
  static let left = Self([.topLeft, .bottomLeft])
  static let right = Self([.topRight, .bottomRight])
  static let null = Self([])
}

extension Side {
  var opposite: Self {
    .init(corners.map { $0.opposite })
  }
}

// MARK: - ConstructablePathComponent

/// A type that represents a component in a constructable path.
enum ConstructablePathComponent {
  /// Closes the path.
  case close

  /// Moves the path to the given point.
  case move(to: CGPoint)

  /// Draws a line in the path from its current point to the given point.
  case line(to: CGPoint)

  /// Draws a curved line in the path from its current point to the given
  /// point, using the provided control points to determine the curve's shape.
  case curve(to: CGPoint, c1: CGPoint, c2: CGPoint)

  /// A component that nests other components.
  ///
  /// This case can be created using array literal syntax.
  /// ```swift
  /// let c1 = ConstructablePathComponent.compound([
  ///     .move(to: point1),
  ///     .line(to: point2),
  /// ])
  ///
  /// let c2: ConstructablePathComponent = [
  ///     .move(to: point1),
  ///     .line(to: point2),
  /// ]
  ///
  /// print(c1 == c2) // Prints: true
  /// ```
  indirect case compound([Self])
}

// MARK: ConstructablePathComponent Helpers
extension ConstructablePathComponent {
  /// Returns a compound component that constructs a right angle curve around
  /// the given corner of the provided rectangle, using the provided radius and inset.
  static func rightAngleCurve(
    around corner: Corner,
    ofRect rect: CGRect,
    radius r: CGFloat,
    inset amount: CGFloat
  ) -> Self {
    let rX = min(r, rect.width / 2)
    let rY = min(r, rect.height / 2)
    let inset = rect.insetBy(dx: -amount, dy: -amount)
    switch corner {
    case .topLeft:
      return [
        .line(to: rect.topLeft.translating(y: -rY)),
        .curve(to: rect.topLeft.translating(x: rX), c1: inset.topLeft, c2: inset.topLeft),
      ]
    case .topRight:
      return [
        .line(to: rect.topRight.translating(x: -rX)),
        .curve(to: rect.topRight.translating(y: -rY), c1: inset.topRight, c2: inset.topRight),
      ]
    case .bottomRight:
      return [
        .line(to: rect.bottomRight.translating(y: rY)),
        .curve(to: rect.bottomRight.translating(x: -rX), c1: inset.bottomRight, c2: inset.bottomRight),
      ]
    case .bottomLeft:
      return [
        .line(to: rect.bottomLeft.translating(x: rX)),
        .curve(to: rect.bottomLeft.translating(y: rY), c1: inset.bottomLeft, c2: inset.bottomLeft),
      ]
    default:
      corner.assertionInvalid()
      return []
    }
  }

  /// Returns a Boolean value that indicates whether this component is equal to, or
  /// (if this component is a `compound(_:)` component) whether its nested components
  /// contain the given component.
  func contains(_ other: Self) -> Bool {
    switch self {
    case .compound(let components):
      return components.contains {
        $0.contains(other)
      }
    default:
      return other == self
    }
  }
}

extension ConstructablePathComponent: Equatable { }

extension ConstructablePathComponent: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: Self...) {
    self = .compound(elements)
  }
}

// MARK: - ConstructablePath

/// A type that can produce a version of itself that can be constructed
/// from `ConstructablePathComponent` values.
internal protocol ConstructablePath<Constructed, MutablePath> {
  /// The constructed result.
  associatedtype Constructed: ConstructablePath<Constructed, MutablePath>

  /// A mutable version of this type, that produces the same constructed result.
  associatedtype MutablePath: MutableConstructablePath<Constructed, MutablePath>

  /// This path, as its constructed result type.
  var asConstructedType: Constructed { get }

  /// Constructs a path from the given components.
  ///
  /// - Parameters:
  ///   - components: The components to construct the path with.
  /// - Returns: A `Constructed`-typed path, constructed using `components`.
  static func constructed(with components: [ConstructablePathComponent]) -> Constructed
}

extension ConstructablePath where Constructed == Self {
  internal var asConstructedType: Self { self }
}

extension ConstructablePath {
  internal static func constructed(with components: [ConstructablePathComponent]) -> Constructed {
    let path = MutablePath()
    for component in components {
      path.apply(component)
    }
    return path.asConstructedType
  }
}

// MARK: Color Well Path
extension ConstructablePath {
  /// Produces a path for a part of a color well.
  ///
  /// - Parameters:
  ///   - rect: The rectangle to draw the path in.
  ///   - corners: The corners that should be drawn with sharp right angles.
  ///     Corners not provided here will be rounded.
  internal static func colorWellPath(
    rect: CGRect,
    squaredCorners corners: [Corner] = []
  ) -> Constructed {
    let radius: CGFloat = 14
    let amount = ColorWell.lineWidth / 2
    var components: [ConstructablePathComponent] = Corner.all.map {
      if corners.contains($0) {
        return .line(to: rect[keyPath: $0])
      }
      return .rightAngleCurve(around: $0, ofRect: rect, radius: radius, inset: amount)
    }
    components.append(.close)
    return .constructed(with: components)
  }

  internal static func colorWellSegment(rect: CGRect, side: Side) -> Constructed {
    colorWellPath(rect: rect, squaredCorners: side.opposite.corners)
  }
}

// MARK: - MutableConstructablePath

/// A constructable path type whose instances can be altered with
/// path components after their creation.
internal protocol MutableConstructablePath<Constructed, MutablePath>: ConstructablePath {
  init()

  /// Applies the given path component to this path.
  func apply(_ component: ConstructablePathComponent)
}

// MARK: - Implementations

// MARK: NSBezierPath MutableConstructablePath
extension NSBezierPath: MutableConstructablePath {
  internal typealias MutablePath = NSBezierPath

  internal func apply(_ component: ConstructablePathComponent) {
    switch component {
    case .close:
      close()
    case .move(let point):
      move(to: point)
    case .line(let point):
      if isEmpty {
        move(to: point)
      } else {
        line(to: point)
      }
    case .curve(let point, let c1, let c2):
      if isEmpty {
        move(to: point)
      } else {
        curve(to: point, controlPoint1: c1, controlPoint2: c2)
      }
    case .compound(let components):
      for component in components {
        apply(component)
      }
    }
  }
}

// MARK: CGMutablePath MutableConstructablePath
extension CGMutablePath: MutableConstructablePath {
  internal func apply(_ component: ConstructablePathComponent) {
    switch component {
    case .close:
      closeSubpath()
    case .move(let point):
      move(to: point)
    case .line(let point):
      if isEmpty {
        move(to: point)
      } else {
        addLine(to: point)
      }
    case .curve(let point, let c1, let c2):
      if isEmpty {
        move(to: point)
      } else {
        addCurve(to: point, control1: c1, control2: c2)
      }
    case .compound(let components):
      for component in components {
        apply(component)
      }
    }
  }
}

// MARK: CGPath ConstructablePath
extension CGPath: ConstructablePath {
  internal typealias MutablePath = CGMutablePath
}
