//
// ColorWellConfiguration.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorWellConfiguration

/// A type containing information used to configure a color well.
@available(macOS 10.15, *)
struct ColorWellConfiguration {

    // MARK: Properties

    /// The color well's initial color value.
    let color: NSColor?

    /// A constructor for a binding to the color well's color.
    let makeColorBinding: () -> Binding<NSColor?>

    /// An optional action to add to the color well.
    let action: ((NSColor) -> Void)?

    /// An optional label view that is displayed adjacent to
    /// the color well.
    let label: AnyView?

    /// A closure that informs the color well whether or not
    /// it should support alpha values.
    let updateShowsAlpha: (ColorWell) -> Void

    // MARK: Initializers

    /// Creates a configuration using the specified modifiers.
    ///
    /// If more than one of the same modifier is provided, the
    /// one which occurs last will be used.
    init(modifiers: [Modifier?]) {
        typealias Values = (
            color: NSColor?,
            makeColorBinding: () -> Binding<NSColor?>,
            action: ((NSColor) -> Void)?,
            label: AnyView?,
            updateShowsAlpha: (ColorWell) -> Void
        )

        var values: Values = (nil, { .constant(nil) }, nil, nil, { _ in })

        for case .some(let modifier) in modifiers {
            switch modifier {
            case .color(let color):
                values.color = color
            case .optionalCocoaColorBinding(let binding):
                values.makeColorBinding = binding
            case .action(let action):
                values.action = action
            case .label(let label):
                values.label = label.erased()
            case .showsAlpha(let showsAlpha):
                values.updateShowsAlpha = { colorWell in
                    colorWell.showsAlphaForcedState = showsAlpha.wrappedValue
                }
            }
        }

        self.color = values.color
        self.makeColorBinding = values.makeColorBinding
        self.action = values.action
        self.label = values.label
        self.updateShowsAlpha = values.updateShowsAlpha
    }
}

// MARK: ColorWellConfiguration.Modifier
@available(macOS 10.15, *)
extension ColorWellConfiguration {
    /// A type that modifies a value in a `ColorWellConfiguration`.
    enum Modifier {
        /// Sets the configuration's color to the given value.
        case color(NSColor)

        /// Provides a binding to an optional `Cocoa` color.
        /// Do not use this modifier directly.
        case optionalCocoaColorBinding(@autoclosure () -> Binding<NSColor?>)

        /// Sets the configuration's action to the given closure.
        case action((NSColor) -> Void)

        /// Sets the configuration's label to the given view.
        case label(any View)

        /// Sets the value of the configuration's `showsAlpha`
        /// property to the value stored by the given binding.
        case showsAlpha(Binding<Bool>)
    }
}

// MARK: Modifier Constructors
@available(macOS 10.15, *)
extension ColorWellConfiguration.Modifier {
    /// Sets the configuration's color to the given value.
    @available(macOS 11.0, *)
    static func color(_ color: Color) -> Self {
        Self.color(NSColor(color))
    }

    /// Sets the configuration's color to the given value.
    ///
    /// - Note: If the conversion from `CGColor` to `NSColor`
    ///   fails, this modifier will return `nil`.
    static func cgColor(_ cgColor: CGColor) -> Self? {
        NSColor(cgColor: cgColor).map(Self.color)
    }

    /// Provides a binding to a color.
    @available(macOS 11.0, *)
    static func colorBinding(_ binding: Binding<Color>) -> Self {
        func thunk(_ binding: Binding<Color>) -> Binding<NSColor?> {
            let optional: Binding<Color?> = Binding(binding)
            return Binding(
                get: {
                    optional.wrappedValue.map(NSColor.init)
                },
                set: { color in
                    optional.wrappedValue = color.map(Color.init)
                }
            )
        }

        return Self.optionalCocoaColorBinding(thunk(binding))
    }

    /// Provides a binding to a color.
    static func cgColorBinding(_ binding: Binding<CGColor>) -> Self {
        func thunk(_ binding: Binding<CGColor>) -> Binding<NSColor?> {
            let optional: Binding<CGColor?> = Binding(binding)
            return Binding(
                get: {
                    optional.wrappedValue.flatMap(NSColor.init)
                },
                set: { color in
                    optional.wrappedValue = color?.cgColor
                }
            )
        }

        return Self.optionalCocoaColorBinding(thunk(binding))
    }

    /// Sets the configuration's action to the given closure.
    static func action(_ action: @escaping (Color) -> Void) -> Self {
        Self.action { color in
            action(Color(color))
        }
    }

    /// Sets the configuration's action to the given closure.
    static func action(_ action: @escaping (CGColor) -> Void) -> Self {
        Self.action { color in
            action(color.cgColor)
        }
    }

    /// Sets the configuration's label to the view returned from
    /// the given closure.
    static func label(_ label: () -> any View) -> Self {
        Self.label(label())
    }

    /// Sets the configuration's label to a text view constructed
    /// using the given string.
    static func title<S: StringProtocol>(_ title: S) -> Self {
        Self.label(Text(title))
    }

    /// Sets the configuration's label to a text view constructed
    /// using the given localized string key.
    static func titleKey(_ titleKey: LocalizedStringKey) -> Self {
        Self.label(Text(titleKey))
    }

    /// Sets the value of the configuration's `showsAlpha` property
    /// to a constant binding derived from the given Boolean value.
    static func supportsOpacity(_ supportsOpacity: Bool) -> Self {
        Self.showsAlpha(.constant(supportsOpacity))
    }
}
#endif
