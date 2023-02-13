//===----------------------------------------------------------------------===//
//
// Extensions.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

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
    internal func applying(_ insets: NSEdgeInsets) -> Self {
        Self(
            width: width - insets.horizontal,
            height: height - insets.vertical
        )
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
    /// The current color, using the `sRGB` color space.
    internal var sRGB: NSColor? {
        usingColorSpace(.sRGB)
    }

    /// The `sRGB` color space components of the current color.
    internal var sRGBComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let sRGB else {
            return nil
        }
        let r = sRGB.redComponent
        let g = sRGB.greenComponent
        let b = sRGB.blueComponent
        let a = sRGB.alphaComponent
        return (r, g, b, a)
    }

    /// Returns the average of this color's red, green, and blue components,
    /// approximating the brightness of the color.
    internal var averageBrightness: CGFloat {
        guard let sRGBComponents else {
            return 0
        }
        return (sRGBComponents.red + sRGBComponents.green + sRGBComponents.blue) / 3
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
        let aString = {
            if count == 6 {
                return "ff"
            } else {
                return hexArray[6..<8].joined()
            }
        }()

        let rInt = Int(rString, radix: 16)!
        let gInt = Int(gString, radix: 16)!
        let bInt = Int(bString, radix: 16)!
        let aInt = Int(aString, radix: 16)!

        let rFloat = CGFloat(rInt) / 255
        let gFloat = CGFloat(gInt) / 255
        let bFloat = CGFloat(bInt) / 255
        let aFloat = CGFloat(aInt) / 255

        self.init(srgbRed: rFloat, green: gFloat, blue: bFloat, alpha: aFloat)
    }

    /// Creates a value containing a description of the color, for use with
    /// accessibility features.
    internal func createAccessibilityValue() -> String {
        ComponentFormatter(color: self).string ?? ""
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
    /// This method checks all typical color spaces.
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

        let standardColorSpaces: [NSColorSpace] = [
            .sRGB,
            .extendedSRGB,
            .adobeRGB1998,
            .displayP3,
        ]

        for colorSpace in standardColorSpaces where resembles(other, using: colorSpace, tolerance: tolerance) {
            return true
        }

        let genericColorSpaces: [NSColorSpace] = [
            .genericRGB,
            .genericCMYK,
            .genericGray,
            .genericGamma22Gray,
            .extendedGenericGamma22Gray,
        ]

        for colorSpace in genericColorSpaces where resembles(other, using: colorSpace, tolerance: tolerance) {
            return true
        }

        let deviceColorSpaces: [NSColorSpace] = [
            .deviceRGB,
            .deviceCMYK,
            .deviceGray,
        ]

        for colorSpace in deviceColorSpaces where resembles(other, using: colorSpace, tolerance: tolerance) {
            return true
        }

        return false
    }
}

// MARK: - NSColorPanel

extension NSColorPanel {
    /// Backing storage for the `activeColorWells` instance property.
    private static let storage = Storage<Set<ColorWell>>()

    /// The color wells that are currently active and share this color panel.
    internal var activeColorWells: Set<ColorWell> {
        get {
            Self.storage[self] ?? []
        }
        set {
            if newValue.isEmpty {
                Self.storage[self] = nil
            } else {
                Self.storage[self] = newValue
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
        let context = current
        context?.saveGraphicsState()
        defer {
            context?.restoreGraphicsState()
        }
        return try body(context)
    }

    /// Executes a block of code on the current graphics context, restoring
    /// the graphics state after the block returns.
    internal static func withCachedGraphicsState<T>(_ body: () throws -> T) rethrows -> T {
        try withCachedGraphicsState { _ in
            try body()
        }
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
    /// Stores this key-value observation in the specified collection.
    ///
    /// - Parameter collection: The collection in which to store this observation.
    internal func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == NSKeyValueObservation {
        collection.append(self)
    }

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
