//===----------------------------------------------------------------------===//
//
// ConstructablePath.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

// MARK: - Corner

/// A type that represents a corner of a rectangle.
internal enum Corner {
    /// The top left corner of a rectangle.
    case topLeft

    /// The top right corner of a rectangle.
    case topRight

    /// The bottom left corner of a rectangle.
    case bottomLeft

    /// The bottom right corner of a rectangle.
    case bottomRight

    /// The valid corners that can be used during path construction.
    ///
    /// - Important: The order of elements in the array is the order that is
    ///   used during color well path construction, starting at the top left
    ///   and moving clockwise around the color well's border.
    static let clockwiseOrder: [Self] = [.topLeft, .topRight, .bottomRight, .bottomLeft]
}

// MARK: Corner Helpers
extension Corner {
    /// The corner at the opposite end of the rectangle from this corner.
    ///
    /// For example, if this corner is `topLeft`, its `opposite` corner
    /// will be `bottomRight`.
    var opposite: Self {
        switch self {
        case .topLeft:
            return .bottomRight
        case .topRight:
            return .bottomLeft
        case .bottomLeft:
            return .topRight
        case .bottomRight:
            return .topLeft
        }
    }

    /// Returns the point in the given rectangle that corresponds to this corner.
    func point(forRect rect: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.minY)
        }
    }
}

// MARK: - Side

/// A type that represents a side of a rectangle.
internal struct Side {
    /// The corners that, when connected by a path, make up this side.
    let corners: [Corner]

    /// Creates a side with the given corners.
    private init(_ corners: [Corner]) {
        self.corners = corners
    }
}

// MARK: Side Static Members
extension Side {
    /// The top side of a rectangle.
    static let top = Self([.topLeft, .topRight])

    /// The bottom side of a rectangle.
    static let bottom = Self([.bottomLeft, .bottomRight])

    /// The left side of a rectangle.
    static let left = Self([.topLeft, .bottomLeft])

    /// The right side of a rectangle.
    static let right = Self([.topRight, .bottomRight])

    /// A side that contains no points.
    static let null = Self([])
}

// MARK: Side Helpers
extension Side {
    /// The side on the opposite end of the rectangle.
    ///
    /// For example, if this side is `top`, its `opposite`
    /// side will be `bottom`.
    var opposite: Self {
        Self(corners.map { $0.opposite })
    }
}

// MARK: - ConstructablePathComponent

/// A type that represents a component in a constructable path.
internal enum ConstructablePathComponent {
    /// Closes the path.
    case close

    /// Moves the path to the given point.
    case move(to: CGPoint)

    /// Draws a line in the path from its current point to the given point.
    case line(to: CGPoint)

    /// Draws a curved line in the path from its current point to the given
    /// point, using the provided control points to determine the curve's shape.
    case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)

    /// Draws an arc in the path from its current point, through the given
    /// midpoint, to the given endpoint, curving the path to the specified
    /// radius.
    case arc(through: CGPoint, to: CGPoint, radius: CGFloat)

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
    static func rightAngleCurve(around corner: Corner, ofRect rect: CGRect, radius: CGFloat) -> Self {
        let mid: CGPoint
        let start: CGPoint
        let end: CGPoint

        switch corner {
        case .topLeft:
            mid = corner.point(forRect: rect)
            start = mid.translating(y: -radius)
            end = mid.translating(x: radius)
        case .topRight:
            mid = corner.point(forRect: rect)
            start = mid.translating(x: -radius)
            end = mid.translating(y: -radius)
        case .bottomRight:
            mid = corner.point(forRect: rect)
            start = mid.translating(y: radius)
            end = mid.translating(x: -radius)
        case .bottomLeft:
            mid = corner.point(forRect: rect)
            start = mid.translating(x: radius)
            end = mid.translating(y: radius)
        }

        return [
            .line(to: start),
            .arc(through: mid, to: end, radius: radius),
        ]
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

// MARK: ConstructablePathComponent: Equatable
extension ConstructablePathComponent: Equatable { }

// MARK: ConstructablePathComponent: ExpressibleByArrayLiteral
extension ConstructablePathComponent: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Self...) {
        self = .compound(elements)
    }
}

// MARK: - ConstructablePath

/// A type that can produce a version of itself that can be constructed
/// from `ConstructablePathComponent` values.
internal protocol ConstructablePath<Constructed, MutablePath> {
    /// The constructed result of this path type.
    associatedtype Constructed: ConstructablePath<Constructed, MutablePath>

    /// A mutable version of this type, that produces the same constructed result.
    associatedtype MutablePath: MutableConstructablePath<Constructed, MutablePath>

    /// This path, as its constructed result type.
    var asConstructedType: Constructed { get }

    /// Constructs a path from the given components.
    ///
    /// - Parameter components: The components to use to construct the path.
    /// - Returns: A `Constructed`-typed path, constructed using `components`.
    static func construct(with components: [ConstructablePathComponent]) -> Constructed
}

// MARK: - ConstructablePath Default Implementations

// MARK: ConstructablePath (Constructed == Self)
extension ConstructablePath where Constructed == Self {
    internal var asConstructedType: Constructed { self }
}

// MARK: ConstructablePath Construct
extension ConstructablePath {
    internal static func construct(with components: [ConstructablePathComponent]) -> Constructed {
        let path = MutablePath()
        for component in components {
            path.apply(component)
        }
        return path.asConstructedType
    }
}

// MARK: ConstructablePath Helpers
extension ConstructablePath {
    /// Produces a path for a part of a color well.
    ///
    /// - Parameters:
    ///   - rect: The rectangle to draw the path in.
    ///   - corners: The corners that should be drawn with sharp right
    ///     angles. Corners not provided here will be rounded.
    internal static func colorWellPath(
        rect: CGRect,
        squaredCorners corners: [Corner] = []
    ) -> Constructed {
        var components: [ConstructablePathComponent] = Corner.clockwiseOrder.map {
            if corners.contains($0) {
                return .line(to: $0.point(forRect: rect))
            }
            return .rightAngleCurve(around: $0, ofRect: rect, radius: 5.5)
        }
        components.append(.close)
        return .construct(with: components)
    }

    /// Produces a color well segment path for the specified side of
    /// a rectangle.
    ///
    /// - Parameters:
    ///   - rect: The rectangle to draw the path in.
    ///   - side: The side of `rect` that the path should be drawn in.
    ///     > Note: This parameter implies which corners should be rounded
    ///       and which corners should be drawn with sharp right angles.
    internal static func colorWellSegment(rect: CGRect, side: Side) -> Constructed {
        colorWellPath(rect: rect, squaredCorners: side.opposite.corners)
    }
}

// MARK: - MutableConstructablePath

/// A constructable path type whose instances can be altered with
/// path components after their creation.
internal protocol MutableConstructablePath<Constructed, MutablePath>: ConstructablePath {
    /// Creates an empty mutable constructable path.
    init()

    /// Applies the given path component to this path.
    func apply(_ component: ConstructablePathComponent)
}

// MARK: - Implementations

// MARK: NSBezierPath: MutableConstructablePath
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
        case .curve(let point, let control1, let control2):
            if isEmpty {
                move(to: point)
            } else {
                curve(to: point, controlPoint1: control1, controlPoint2: control2)
            }
        case .arc(let midPoint, let endPoint, let radius):
            if isEmpty {
                move(to: endPoint)
            } else {
                appendArc(from: midPoint, to: endPoint, radius: radius)
            }
        case .compound(let components):
            for component in components {
                apply(component)
            }
        }
    }
}

// MARK: CGMutablePath: MutableConstructablePath
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
        case .curve(let point, let control1, let control2):
            if isEmpty {
                move(to: point)
            } else {
                addCurve(to: point, control1: control1, control2: control2)
            }
        case .arc(let midPoint, let endPoint, let radius):
            if isEmpty {
                move(to: endPoint)
            } else {
                addArc(tangent1End: midPoint, tangent2End: endPoint, radius: radius)
            }
        case .compound(let components):
            for component in components {
                apply(component)
            }
        }
    }
}

// MARK: CGPath: ConstructablePath
extension CGPath: ConstructablePath {
    internal typealias MutablePath = CGMutablePath
}
