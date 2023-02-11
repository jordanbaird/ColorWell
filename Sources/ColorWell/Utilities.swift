//===----------------------------------------------------------------------===//
//
// Utilities.swift
//
//===----------------------------------------------------------------------===//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Counter

/// A counter type whose value is incremented on access.
internal struct Counter {
    /// A pointer to the counter's value.
    ///
    /// We use a pointer instead of an integer to avoid the use of
    /// mutable counters (accidental reassignment would invalidate
    /// all previous and future values).
    ///
    /// Using a class instead of a struct would accomplish the same
    /// thing, but we want to keep things as lightweight as possible.
    private let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)

    /// Creates a counter initialized to `0`.
    init() {
        pointer.initialize(to: 0)
    }

    /// Returns the current value and increments the counter.
    func bump() -> Int {
        defer {
            pointer.pointee += 1
        }
        return pointer.pointee
    }
}

// MARK: - ComparableID

/// A unique identifier that can be compared by order of creation.
///
/// For identifiers `id1` and `id2`, `id1 < id2` if `id1` was created
/// first.
internal struct ComparableID {
    private static let counter = Counter()

    private let uuid = UUID()
    private let count = counter.bump()

    /// Creates a unique identifier that can be compared with other
    /// instances of this type according to the order in which they
    /// were created.
    init() { }
}

// MARK: ComparableID: Comparable
extension ComparableID: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.count < rhs.count
    }
}

// MARK: ComparableID: Equatable
extension ComparableID: Equatable { }

// MARK: ComparableID: Hashable
extension ComparableID: Hashable { }

// MARK: - ChangeHandler

/// An identifiable, hashable wrapper for a change handler that is
/// executed when a color well's color changes.
///
/// This type can be compared by order of creation.
///
/// For handlers `h1` and `h2`, `h1 < h2` if `h1` was created first.
internal struct ChangeHandler {
    private let id: ComparableID
    private let handler: (NSColor) -> Void

    /// Creates a change handler with the given identifier and closure.
    ///
    /// - Parameters:
    ///   - id: An identifier that can be compared by order of creation.
    ///   - handler: A closure to store for later execution.
    init(id: ComparableID, handler: @escaping (NSColor) -> Void) {
        self.id = id
        self.handler = handler
    }

    /// Creates a change handler from a closure.
    ///
    /// This initializer automatically creates the handler's identifier.
    ///
    /// - Parameter handler: A closure to store for later execution.
    init(handler: @escaping (NSColor) -> Void) {
        self.init(id: ComparableID(), handler: handler)
    }

    /// Invokes the closure that is stored by this instance, passing the
    /// given color as an argument.
    ///
    /// - Parameter color: The color to pass into the handler's closure.
    func callAsFunction(_ color: NSColor) {
        handler(color)
    }
}

// MARK: ChangeHandler: Comparable
extension ChangeHandler: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id < rhs.id
    }
}

// MARK: ChangeHandler: Equatable
extension ChangeHandler: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: ChangeHandler: Hashable
extension ChangeHandler: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Storage

/// A type that uses object association to store external values.
internal class Storage<Value> {
    private let policy: AssociationPolicy

    private var key: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }

    /// Creates a storage object that stores values of the
    /// given type, using the provided association policy.
    init(
        _ type: Value.Type = Value.self,
        policy: @autoclosure () -> AssociationPolicy = .retain(false)
    ) {
        self.policy = policy()
    }

    /// Accesses the value for the given object.
    subscript<Object: AnyObject>(_ object: Object) -> Value? {
        get { objc_getAssociatedObject(object, key) as? Value }
        set { objc_setAssociatedObject(object, key, newValue, policy.objcValue) }
    }
}

// MARK: - AssociationPolicy

/// A type that specifies the behavior of an object association.
internal struct AssociationPolicy {
    fileprivate let objcValue: objc_AssociationPolicy

    private init(_ objcValue: objc_AssociationPolicy) {
        self.objcValue = objcValue
    }
}

// MARK: AssociationPolicy Static Members
extension AssociationPolicy {
    /// A weak reference to the associated object.
    static var assign: Self {
        Self(.OBJC_ASSOCIATION_ASSIGN)
    }

    /// The associated object is copied.
    static func copy(_ isAtomic: Bool) -> Self {
        guard isAtomic else {
            return Self(.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        return Self(.OBJC_ASSOCIATION_COPY)
    }

    /// A strong reference to the associated object.
    static func retain(_ isAtomic: Bool) -> Self {
        guard isAtomic else {
            return Self(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return Self(.OBJC_ASSOCIATION_RETAIN)
    }
}

// MARK: - ComponentFormatter

/// A specialized number formatter that formats the components of
/// a color for display as an accessibility value.
internal struct ComponentFormatter {
    /// The color that is formatted by this formatter.
    let color: NSColor

    /// Returns a basic description of the formatter's color,
    /// alongside the components for the color's current color space.
    private var simpleDescriptionAndComponents: (description: String, components: [Double]) {
        switch color.colorSpace.colorSpaceModel {
        case .rgb:
            return ("rgb", [
                color.redComponent,
                color.greenComponent,
                color.blueComponent,
                color.alphaComponent,
            ])
        case .cmyk:
            return ("cmyk", [
                color.cyanComponent,
                color.magentaComponent,
                color.yellowComponent,
                color.blackComponent,
                color.alphaComponent,
            ])
        case .deviceN:
            return ("deviceN", [])
        case .gray:
            return ("grayscale", [
                color.whiteComponent,
                color.alphaComponent,
            ])
        case .indexed:
            return ("indexed", [])
        case .lab:
            return ("L*a*b*", [])
        case .patterned:
            return ("pattern", [])
        case .unknown:
            break
        @unknown default:
            break
        }
        return ("\(color)", [])
    }

    /// Returns a string containing a description of the formatter's
    /// color, for use with accessibility features.
    var string: String? {
        switch color.type {
        case .componentBased:
            let extracted = simpleDescriptionAndComponents

            guard
                !extracted.components.isEmpty,
                extracted.components.count == color.numberOfComponents
            else {
                // Returning a generic description is the best we can do.
                // Example: "rgb color"
                return "\(extracted.description) color"
            }

            let fmt = NumberFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.minimumIntegerDigits = 1
            fmt.minimumFractionDigits = 0
            fmt.maximumFractionDigits = 6
            fmt.nilSymbol = NilSentinel.nilSymbol

            var results = [extracted.description]

            for component in extracted.components {
                guard
                    let string = fmt.string(for: component),
                    string != NilSentinel.nilSymbol
                else {
                    return nil
                }
                results.append(string)
            }

            return results.joined(separator: " ")
        case .catalog:
            return "catalog color \(color.localizedColorNameComponent)"
        case .pattern:
            return "pattern"
        @unknown default:
            break
        }
        return "\(color)"
    }
}

// MARK: - ComponentFormatter NilSentinel

extension ComponentFormatter {
    /// A type that serves as the base for a sentinel value indicating
    /// that a component formatter's underlying number formatter produced
    /// a `nil` string.
    private enum NilSentinel {
        /// The sentinel value produced by this type.
        static let nilSymbol = "\(Self.self)(" + String(ObjectIdentifier(Self.self).hashValue) + ")"
    }
}

// MARK: - SwiftUI Utilities

#if canImport(SwiftUI)

// MARK: - ViewConstructor

@available(macOS 10.15, *)
internal struct ViewConstructor<Content: View>: View {
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
        ViewConstructor<Modified>(content: block(content))
    }

    func erased() -> AnyViewConstructor {
        AnyViewConstructor(base: self)
    }
}

// MARK: - AnyViewConstructor

@available(macOS 10.15, *)
internal struct AnyViewConstructor: View {
    let base: any View

    var body: some View {
        AnyView(base)
    }

    init<Content: View>(base: ViewConstructor<Content>) {
        self.base = base
    }

    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.init(base: ViewConstructor(content: content))
    }

    init<Content: View>(content: @autoclosure () -> Content) {
        self.init(content: content)
    }
}

// MARK: - CustomCocoaConvertible

/// A type that can be converted from an equivalent type
/// in the `Cocoa` framework.
internal protocol CustomCocoaConvertible {
    /// This type's equivalent type in the `Cocoa` framework.
    associatedtype CocoaType: NSObject

    /// The `CustomCocoaConvertible` type that is created from
    /// this type's `CocoaType`.
    ///
    /// This type defaults to `Self`, but can be redefined if
    /// semantically necessary.
    associatedtype Converted: CustomCocoaConvertible = Self

    /// Converts an instance of this type's `CocoaType` to an
    /// instance of this type's `Converted` type.
    static func converted(from source: CocoaType) -> Converted
}

// MARK: Color: CustomCocoaConvertible
@available(macOS 10.15, *)
extension Color: CustomCocoaConvertible {
    internal static func converted(from source: NSColor) -> Self {
        Self(source)
    }
}

// MARK: CGColor: CustomCocoaConvertible
extension CGColor: CustomCocoaConvertible {
    internal static func converted(from source: NSColor) -> CGColor {
        source.cgColor
    }
}
#endif
