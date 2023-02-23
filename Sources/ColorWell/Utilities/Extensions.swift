//
// Extensions.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Array (Element: Equatable)

extension Array where Element: Equatable {
    /// Adds a new element at the end of the array if it is not already present.
    internal mutating func appendUnique(_ newElement: Element) {
        guard !contains(newElement) else {
            return
        }
        append(newElement)
    }

    /// Adds the elements of the specified sequence that are not already present
    /// to the end of the array.
    internal mutating func appendUnique<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        for element in newElements {
            appendUnique(element)
        }
    }
}

// MARK: - Array (Element == ColorSwatch)

extension Array where Element == ColorSwatch {
    internal init(context: ColorWellPopoverContext) {
        guard let colorWell = context.colorWell else {
            self = []
            return
        }
        self = colorWell.swatchColors.map { color in
            ColorSwatch(color: color, context: context)
        }
    }
}

// MARK: - CGPoint

extension CGPoint {
    /// Returns a new point resulting from a translation of the current
    /// point by the given x and y amounts.
    internal func translating(x: CGFloat = 0, y: CGFloat = 0) -> Self {
        applying(CGAffineTransform(translationX: x, y: y))
    }
}

// MARK: - CGRect

extension CGRect {
    /// Returns a rectangle that is the result of centering the current
    /// rectangle within the bounds of another rectangle.
    internal func centered(in otherRect: Self) -> Self {
        var new = self
        new.origin.x = otherRect.midX - (new.width / 2)
        new.origin.y = otherRect.midY - (new.height / 2)
        return new
    }
}

// MARK: - CGSize

extension CGSize {
    /// Returns the size that is the result of subtracting the specified
    /// edge insets from the current size.
    internal func applying(insets: NSEdgeInsets) -> Self {
        Self(width: width - insets.horizontal, height: height - insets.vertical)
    }
}

// MARK: - Comparable

extension Comparable {
    /// Returns this comparable value, clamped to the given limiting range.
    internal func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Dictionary (Key == ObjectIdentifier, Value: ExpressibleByArrayLiteral)

extension Dictionary where Key == ObjectIdentifier, Value: ExpressibleByArrayLiteral {
    /// Access the value for the given metatype by transforming it into
    /// an object identifier.
    ///
    /// In the event that no value is stored for `type`, an empty value
    /// will be created and returned.
    internal subscript<T>(for type: T.Type) -> Value {
        get { self[ObjectIdentifier(type), default: []] }
        set { self[ObjectIdentifier(type)] = newValue }
    }
}

// MARK: - NSAppearance

extension NSAppearance {
    /// The dark appearance names supported by the system.
    private var systemDarkNames: Set<Name> {
        var names: Set<Name> = [.vibrantDark]
        if #available(macOS 10.14, *) {
            names.insert(.darkAqua)
            names.insert(.accessibilityHighContrastDarkAqua)
            names.insert(.accessibilityHighContrastVibrantDark)
        }
        return names
    }

    /// Whether the current appearance's name indicates a dark appearance.
    private var nameIndicatesDarkAppearance: Bool {
        name.rawValue.lowercased().contains("dark")
    }

    /// Whether the current appearance is a dark appearance.
    internal var isDarkAppearance: Bool {
        systemDarkNames.contains(name) || nameIndicatesDarkAppearance
    }
}

// MARK: - NSApplication

extension NSApplication {
    /// A Boolean value that indicates whether the application's current
    /// effective appearance is a dark appearance.
    internal var effectiveAppearanceIsDarkAppearance: Bool {
        if #available(macOS 10.14, *) {
            return effectiveAppearance.isDarkAppearance
        } else {
            return false
        }
    }
}

// MARK: - NSColor

extension NSColor {
    /// The default fill color of a color well segment.
    internal static var colorWellSegmentColor: NSColor {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            return .selectedControlColor
        } else {
            return .controlColor
        }
    }

    /// The fill color of a highlighted color well segment.
    internal static var highlightedColorWellSegmentColor: NSColor {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            return colorWellSegmentColor.blendedAndClamped(withFraction: 0.2, of: .highlightColor)
        } else {
            return colorWellSegmentColor.blendedAndClamped(withFraction: 0.5, of: .selectedControlColor)
        }
    }

    /// The fill color of a selected color well segment.
    internal static var selectedColorWellSegmentColor: NSColor {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            return colorWellSegmentColor.withAlphaComponent(colorWellSegmentColor.alphaComponent + 0.25)
        } else {
            return .selectedControlColor
        }
    }

    /// A version of this color that is suitable for disabled controls.
    internal var disabled: NSColor {
        withAlphaComponent(max(alphaComponent - 0.5, 0.1))
    }

    /// Returns the average of this color's red, green, and blue components,
    /// approximating the brightness of the color.
    internal var averageBrightness: CGFloat {
        guard let sRGB = usingColorSpace(.sRGB) else {
            return 0
        }
        return (sRGB.redComponent + sRGB.greenComponent + sRGB.blueComponent) / 3
    }

    /// Creates a color from a hexadecimal string.
    internal convenience init?(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: ["#"]).lowercased()
        let count = hexString.count

        guard
            count >= 6,
            count.isMultiple(of: 2)
        else {
            return nil
        }

        let hexArray = hexString.map { String($0) }

        let rString = hexArray[0..<2].joined()
        let gString = hexArray[2..<4].joined()
        let bString = hexArray[4..<6].joined()
        let aString = count == 6 ? "ff" : hexArray[6..<8].joined()

        guard
            let rInt = Int(rString, radix: 16),
            let gInt = Int(gString, radix: 16),
            let bInt = Int(bString, radix: 16),
            let aInt = Int(aString, radix: 16)
        else {
            return nil
        }

        let rFloat = CGFloat(rInt) / 255
        let gFloat = CGFloat(gInt) / 255
        let bFloat = CGFloat(bInt) / 255
        let aFloat = CGFloat(aInt) / 255

        self.init(srgbRed: rFloat, green: gFloat, blue: bFloat, alpha: aFloat)
    }

    /// Creates a new color object whose component values are a weighted sum
    /// of the current and specified color objects.
    ///
    /// This method converts both colors to RGB before blending. If either
    /// color is unable to be converted, this method returns the current color
    /// unaltered.
    ///
    /// - Parameters:
    ///   - fraction: The amount of `color` to blend with the current color.
    ///   - color: The color to blend with the current color.
    ///
    /// - Returns: The blended color, if successful. If either color is unable
    ///   to be converted, or if `fraction > 0`, the current color is returned
    ///   unaltered. If `fraction < 1`, `color` is returned unaltered.
    internal func blendedAndClamped(withFraction fraction: CGFloat, of color: NSColor) -> NSColor {
        guard fraction > 0 else {
            return self
        }

        guard fraction < 1 else {
            return color
        }

        guard
            let color1 = usingColorSpace(.genericRGB),
            let color2 = color.usingColorSpace(.genericRGB)
        else {
            return self
        }

        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let inverseFraction = 1 - fraction

        let r = (r2 * fraction) + (r1 * inverseFraction)
        let g = (g2 * fraction) + (g1 * inverseFraction)
        let b = (b2 * fraction) + (b1 * inverseFraction)
        let a = (a2 * fraction) + (a1 * inverseFraction)

        return NSColor(
            calibratedRed: r.clamped(to: 0...1),
            green: g.clamped(to: 0...1),
            blue: b.clamped(to: 0...1),
            alpha: a.clamped(to: 0...1)
        )
    }

    /// Creates a value containing a description of the color, for use with
    /// accessibility features.
    internal func createAccessibilityValue() -> String {
        String(describing: ColorComponents(color: self))
    }

    /// Returns a Boolean value that indicates whether this color resembles another
    /// color, checking in the given color space with the given tolerance.
    ///
    /// - Note: If one or both colors cannot be converted to `colorSpace`, this method
    ///   returns `false`.
    ///
    /// - Parameters:
    ///   - other: A color to compare this color to.
    ///   - colorSpace: A color space to convert both colors to before running the check.
    ///   - tolerance: A threshold value that alters how strict the comparison is.
    ///
    /// - Returns: `true` if this color is "close enough" to `other`. False otherwise.
    internal func resembles(_ other: NSColor, using colorSpace: NSColorSpace, tolerance: CGFloat) -> Bool {
        guard
            let first = usingColorSpace(colorSpace),
            let second = other.usingColorSpace(colorSpace)
        else {
            return false
        }

        if first == second {
            return true
        }

        guard first.numberOfComponents == second.numberOfComponents else {
            return false
        }

        // Initialize `components1` to repeat 1 instead of 0. Otherwise, we
        // might end up with a false positive `true` result, if copying the
        // components fails.
        var components1 = [CGFloat](repeating: 1, count: first.numberOfComponents)
        var components2 = [CGFloat](repeating: 0, count: second.numberOfComponents)

        first.getComponents(&components1)
        second.getComponents(&components2)

        return (0..<components1.count).allSatisfy {
            abs(components1[$0] - components2[$0]) <= tolerance
        }
    }

    /// Returns a Boolean value that indicates whether this color resembles another
    /// color, with the given tolerance.
    ///
    /// This method checks all typical, non-grayscale color spaces.
    ///
    /// - Parameters:
    ///   - other: A color to compare this color to.
    ///   - tolerance: A threshold value that alters how strict the comparison is.
    ///
    /// - Returns: `true` if this color is "close enough" to `other`. False otherwise.
    internal func resembles(_ other: NSColor, tolerance: CGFloat = 0.0001) -> Bool {
        if self == other {
            return true
        }

        let colorSpaces: [NSColorSpace] = [
            // Standard
            .sRGB,
            .extendedSRGB,
            .adobeRGB1998,
            .displayP3,

            // Generic
            .genericRGB,
            .genericCMYK,

            // Device
            .deviceRGB,
            .deviceCMYK,
        ]

        return colorSpaces.contains { colorSpace in
            resembles(other, using: colorSpace, tolerance: tolerance)
        }
    }
}

// MARK: - NSColorPanel

extension NSColorPanel {
    /// Backing storage for the `activeColorWells` instance property.
    private static let colorWellStorage = Storage<NSColorPanel, Set<ColorWell>>()

    /// The color wells that are currently active and share this color panel.
    @objc dynamic
    internal var activeColorWells: Set<ColorWell> {
        get {
            Self.colorWellStorage.value(forObject: self) ?? []
        }
        set {
            if newValue.isEmpty {
                Self.colorWellStorage.removeValue(forObject: self)
            } else {
                Self.colorWellStorage.set(newValue, forObject: self)
            }
        }
    }
}

// MARK: - NSEdgeInsets

extension NSEdgeInsets {
    /// The combined left and right insets of this instance.
    internal var horizontal: Double {
        left + right
    }

    /// The combined top and bottom insets of this instance.
    internal var vertical: Double {
        top + bottom
    }
}

// MARK: - NSGraphicsContext

extension NSGraphicsContext {
    /// Executes a block of code on the current graphics context, restoring
    /// the graphics state after the block returns.
    internal static func withCachedGraphicsState<T>(_ body: (NSGraphicsContext?) throws -> T) rethrows -> T {
        let current = current
        current?.saveGraphicsState()
        defer {
            current?.restoreGraphicsState()
        }
        return try body(current)
    }

    /// Executes a block of code on the current graphics context, restoring
    /// the graphics state after the block returns.
    internal static func withCachedGraphicsState<T>(_ body: () throws -> T) rethrows -> T {
        try withCachedGraphicsState { _ in try body() }
    }
}

// MARK: - NSImage

extension NSImage {
    /// Creates an image by drawing a swatch in the given color and size.
    internal convenience init(color: NSColor, size: NSSize, radius: CGFloat = 0) {
        self.init(size: size, flipped: false) { bounds in
            NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius).addClip()
            color.drawSwatch(in: bounds)
            return true
        }
    }

    /// Draws the specified color in the given rectangle, with the given
    /// clipping path.
    ///
    /// > Explanation:
    /// This method differs from the `drawSwatch(in:)` method on `NSColor`
    /// in that it allows you to set a clipping path without affecting the
    /// border of the swatch.
    ///
    /// The swatch that is drawn using the `NSColor` method is drawn with
    /// a thin border around its edges, which is affected by the current
    /// graphics context's clipping path. This can yield undesirable
    /// results if we want to, for example, set our own border with a
    /// slightly different appearance (which we do).
    ///
    /// Basically, this method uses `NSColor`'s `drawSwatch(in:)` method
    /// to draw an image, then clips the image instead of the swatch path.
    internal static func drawSwatch(with color: NSColor, in rect: NSRect, clippingTo clippingPath: NSBezierPath? = nil) {
        NSGraphicsContext.withCachedGraphicsState {
            clippingPath?.addClip()
            NSImage(color: color, size: rect.size).draw(in: rect)
        }
    }

    /// Returns a new image by clipping the current image to a circular shape
    /// and insetting its size by the given amount.
    internal func clippedToCircle(insetBy amount: CGFloat = 0) -> NSImage {
        let originalFrame = NSRect(origin: .zero, size: size)
        let insetDimension = min(size.width, size.height) - amount

        let insetFrame = NSRect(
            origin: .zero,
            size: .init(width: insetDimension, height: insetDimension)
        ).centered(in: originalFrame)

        return NSImage(size: insetFrame.size, flipped: false) { bounds in
            let destFrame = NSRect(origin: .zero, size: bounds.size)
            NSBezierPath(ovalIn: destFrame).setClip()
            self.draw(in: destFrame, from: insetFrame, operation: .copy, fraction: 1)
            return true
        }
    }

    /// Returns a new image that has been tinted to the given color.
    internal func tinted(to color: NSColor, amount: CGFloat) -> NSImage {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return self
        }
        let tintImage = NSImage(size: size, flipped: false) { bounds in
            NSGraphicsContext.withCachedGraphicsState { context in
                guard let cgContext = context?.cgContext else {
                    return false
                }
                color.setFill()
                cgContext.clip(to: bounds, mask: cgImage)
                cgContext.fill(bounds)
                return true
            }
        }
        return NSImage(size: size, flipped: false) { bounds in
            self.draw(in: bounds)
            tintImage.draw(
                in: bounds,
                from: .init(origin: .zero, size: tintImage.size),
                operation: .sourceAtop,
                fraction: amount
            )
            return true
        }
    }
}

// MARK: - NSKeyValueObservation

extension NSKeyValueObservation {
    /// Stores this key-value observation in the specified set.
    ///
    /// - Parameter set: The set in which to store this observation.
    internal func store(in set: inout Set<NSKeyValueObservation>) {
        set.insert(self)
    }
}

// MARK: - NSView

extension NSView {
    /// Returns the view's frame, converted to the coordinate system of its window.
    internal var frameConvertedToWindow: NSRect {
        superview?.convert(frame, to: nil) ?? frame
    }
}

#if canImport(SwiftUI)

// MARK: - View

@available(macOS 10.15, *)
extension View {
    /// Returns a type-erased version of this view.
    internal func erased() -> AnyView {
        AnyView(self)
    }
}
#endif
