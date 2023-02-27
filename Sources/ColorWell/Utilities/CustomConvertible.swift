//
// CustomConvertible.swift
// ColorWell
//

import Cocoa

// MARK: - CustomConvertible

/// A type that can be converted from an equivalent source type.
internal protocol CustomConvertible {
    /// This type's equivalent source type.
    associatedtype SourceType

    /// The type that is converted from this type's equivalent
    /// source type.
    ///
    /// This type defaults to `Self`, but can be redefined if
    /// semantically necessary.
    associatedtype ConvertedType: CustomConvertible = Self

    /// Returns an instance of this type's converted type from
    /// an instance of this type's equivalent source type.
    static func converted(from source: SourceType) -> ConvertedType
}

// MARK: - CustomNSColorConvertible

/// A `CustomConvertible` type whose equivalent source type
/// is `NSColor`.
internal protocol CustomNSColorConvertible: CustomConvertible where SourceType == NSColor { }

// MARK: CGColor: CustomNSColorConvertible
extension CGColor: CustomNSColorConvertible {
    internal static func converted(from source: NSColor) -> CGColor {
        source.cgColor
    }
}

#if canImport(SwiftUI)
import SwiftUI

// MARK: Color: CustomNSColorConvertible
@available(macOS 10.15, *)
extension Color: CustomNSColorConvertible {
    internal static func converted(from source: NSColor) -> Self {
        Self(source)
    }
}
#endif
