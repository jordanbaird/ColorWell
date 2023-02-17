//===----------------------------------------------------------------------===//
//
// Utilities.swift
//
//===----------------------------------------------------------------------===//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - ChangeHandler

/// An identifiable, hashable wrapper for a change handler that is
/// executed when a color well's color changes.
internal struct ChangeHandler {
    /// A unique identifier for this change handler.
    private let id: UUID

    /// The underlying closure that is executed by this change handler.
    private let action: (NSColor) -> Void

    /// Creates a change handler with the given identifier and closure.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this change handler.
    ///   - handler: A closure to store for later execution.
    init(id: UUID, action: @escaping (NSColor) -> Void) {
        self.id = id
        self.action = action
    }

    /// Creates a change handler from a closure.
    ///
    /// This initializer automatically creates the handler's identifier.
    ///
    /// - Parameter handler: A closure to store for later execution.
    init(action: @escaping (NSColor) -> Void) {
        self.init(id: UUID(), action: action)
    }

    /// Invokes the closure that is stored by this instance, passing the
    /// given color as an argument.
    ///
    /// - Parameter color: The color to pass into the handler's closure.
    func callAsFunction(_ color: NSColor) {
        action(color)
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
internal class Storage<Object: AnyObject, Value> {
    private let policy: AssociationPolicy

    private var key: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }

    /// Creates a storage object that stores external values using
    /// the specified association policy.
    init(policy: AssociationPolicy = .retainNonatomic) {
        self.policy = policy
    }

    /// Accesses the associated value for the specified object.
    func value(forObject object: Object) -> Value? {
        objc_getAssociatedObject(object, key) as? Value
    }

    /// Assigns an associated value to the specified object.
    func set(_ value: Value?, forObject object: Object) {
        objc_setAssociatedObject(object, key, value, policy.objcValue)
    }

    /// Removes the associated value for the specified object.
    func removeValue(forObject object: Object) {
        set(nil, forObject: object)
    }
}

// MARK: - AssociationPolicy

/// Available policies to use for object association.
internal enum AssociationPolicy {
    /// A weak reference to the associated object.
    case assign

    /// The associated object is copied atomically.
    case copy

    /// The associated object is copied nonatomically.
    case copyNonatomic

    /// A strong reference to the associated object that is made atomically.
    case retain

    /// A strong reference to the associated object that is made nonatomically.
    case retainNonatomic

    fileprivate var objcValue: objc_AssociationPolicy {
        switch self {
        case .assign:
            return .OBJC_ASSOCIATION_ASSIGN
        case .copy:
            return .OBJC_ASSOCIATION_COPY
        case .copyNonatomic:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain:
            return .OBJC_ASSOCIATION_RETAIN
        case .retainNonatomic:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        }
    }
}

// MARK: - ColorComponents

/// A type that contains information about the color components for a color.
internal enum ColorComponents {
    case rgb(red: Double, green: Double, blue: Double, alpha: Double)
    case cmyk(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double)
    case grayscale(white: Double, alpha: Double)
    case catalog(name: String)
    case unknown(color: NSColor)
    case deviceN
    case indexed
    case lab
    case pattern
}

// MARK: ColorComponents Properties
extension ColorComponents {
    /// The name of the color space associated with this instance.
    var colorSpaceName: String {
        switch self {
        case .rgb:
            return "rgb"
        case .cmyk:
            return "cmyk"
        case .grayscale:
            return "grayscale"
        case .catalog:
            return "catalog color"
        case .unknown:
            return "unknown color space"
        case .deviceN:
            return "deviceN"
        case .indexed:
            return "indexed"
        case .lab:
            return "L*a*b*"
        case .pattern:
            return "pattern image"
        }
    }

    /// The raw components extracted from this instance.
    var extractedComponents: [Any] {
        switch self {
        case .rgb(let red, let green, let blue, let alpha):
            return [red, green, blue, alpha]
        case .cmyk(let cyan, let magenta, let yellow, let black, let alpha):
            return [cyan, magenta, yellow, black, alpha]
        case .grayscale(let white, let alpha):
            return [white, alpha]
        case .catalog(let name):
            return [name]
        case .unknown(let color):
            guard color.type == .componentBased else {
                return ["\(color)"]
            }

            var components = [CGFloat](repeating: 0, count: color.numberOfComponents)
            color.getComponents(&components)

            return components.map { component in
                Double(component)
            }
        default:
            return []
        }
    }

    /// String representations of the raw components extracted from this instance.
    var extractedComponentStrings: [String] {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6

        return extractedComponents.compactMap { component in
            if let component = component as? Double {
                return formatter.string(for: component)
            }
            return String(describing: component)
        }
    }
}

// MARK: ColorComponents Initializers
extension ColorComponents {
    /// Creates color components from the specified color.
    init(color: NSColor) {
        switch color.type {
        case .componentBased:
            switch color.colorSpace.colorSpaceModel {
            case .rgb:
                self = .rgb(
                    red: color.redComponent,
                    green: color.greenComponent,
                    blue: color.blueComponent,
                    alpha: color.alphaComponent
                )
            case .cmyk:
                self = .cmyk(
                    cyan: color.cyanComponent,
                    magenta: color.magentaComponent,
                    yellow: color.yellowComponent,
                    black: color.blackComponent,
                    alpha: color.alphaComponent
                )
            case .gray:
                self = .grayscale(
                    white: color.whiteComponent,
                    alpha: color.alphaComponent
                )
            case .deviceN:
                self = .deviceN
            case .indexed:
                self = .indexed
            case .lab:
                self = .lab
            case .patterned:
                self = .pattern
            case .unknown:
                self = .unknown(color: color)
            @unknown default:
                self = .unknown(color: color)
            }
        case .pattern:
            self = .pattern
        case .catalog:
            self = .catalog(name: color.localizedColorNameComponent)
        @unknown default:
            self = .unknown(color: color)
        }
    }
}

// MARK: ColorComponents: CustomStringConvertible
extension ColorComponents: CustomStringConvertible {
    var description: String {
        ([colorSpaceName] + extractedComponentStrings).joined(separator: " ")
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

// MARK: CGColor: CustomCocoaConvertible
extension CGColor: CustomCocoaConvertible {
    internal static func converted(from source: NSColor) -> CGColor {
        source.cgColor
    }
}

#if canImport(SwiftUI)
// MARK: Color: CustomCocoaConvertible
@available(macOS 10.15, *)
extension Color: CustomCocoaConvertible {
    internal static func converted(from source: NSColor) -> Self {
        Self(source)
    }
}
#endif
