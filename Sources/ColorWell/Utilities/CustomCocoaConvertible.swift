//===----------------------------------------------------------------------===//
//
// CustomCocoaConvertible.swift
//
//===----------------------------------------------------------------------===//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI
#endif

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
