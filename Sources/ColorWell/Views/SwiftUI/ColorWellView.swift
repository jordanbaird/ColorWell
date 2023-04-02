//
// ColorWellView.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

/// A SwiftUI view that displays a user-selectable color value.
///
/// Color wells provide a means for choosing custom colors directly within
/// your app's user interface. A color well displays the currently selected
/// color, and provides options for selecting new colors. There are a number
/// of styles to choose from, each of which provides a different appearance
/// and set of behaviors.
@available(macOS 10.15, *)
public struct ColorWellView<Label: View>: View {
    /// A type-erased optional label that is displayed adjacent
    /// to the color well.
    private let label: AnyView?

    /// A type-erased `NSViewRepresentable` wrapper around the
    /// view's underlying color well.
    private let representable: AnyView

    /// The content view of the color well.
    public var body: some View {
        if let label {
            HStack(alignment: .center) {
                label
                representable
            }
        } else {
            representable
        }
    }

    /// Creates a color well view using the specified configuration.
    init(configuration: ColorWellConfiguration) {
        label = configuration.label
        representable = {
            ColorWellRepresentable(configuration: configuration)
                .fixedSize()
                .erased()
        }()
    }
}

// MARK: ColorWellView (Label: View)
@available(macOS 10.15, *)
extension ColorWellView {
    // TODO: Deprecate
    /// Creates a color well that uses the provided view as its label,
    /// and executes the given action when its color changes.
    ///
    /// - Parameters:
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    public init(
        cgColor: CGColor,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, with the provided view
    /// being used as the color well's label, and the provided action being executed
    /// when the color well's color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, with the provided view
    /// being used as the color well's label, and the provided action being executed
    /// when the color well's color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(color:supportsOpacity:label:action:)``.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        cgColor: CGColor,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }
}

// MARK: ColorWellView (Label == Never)
@available(macOS 10.15, *)
extension ColorWellView where Label == Never {
    // TODO: Deprecate
    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        supportsOpacity: Bool = true
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init(
        cgColor: CGColor,
        supportsOpacity: Bool = true
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        supportsOpacity: Bool = true,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(color:supportsOpacity:action:)``.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        cgColor: CGColor,
        supportsOpacity: Bool = true,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }
}

// MARK: ColorWellView (Label == Text)
@available(macOS 10.15, *)
extension ColorWellView where Label == Text {

    // MARK: Generate Label From StringProtocol

    // TODO: Deprecate
    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        color: Color,
        supportsOpacity: Bool = true
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        supportsOpacity: Bool = true
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well that generates its label from a string, and
    /// performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(
        _ title: S,
        supportsOpacity: Bool = true,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        color: Color,
        supportsOpacity: Bool = true,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:supportsOpacity:action:)-7turx``.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        supportsOpacity: Bool = true,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }

    // MARK: Generate Label From LocalizedStringKey

    // TODO: Deprecate
    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        color: Color,
        supportsOpacity: Bool = true
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        supportsOpacity: Bool = true
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well that generates its label from a localized
    /// string key, and performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        _ titleKey: LocalizedStringKey,
        supportsOpacity: Bool = true,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        color: Color,
        supportsOpacity: Bool = true,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(color),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }

    // TODO: Deprecate
    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:supportsOpacity:action:)-6lguj``.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        supportsOpacity: Bool = true,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColor(cgColor),
                    .supportsOpacity(supportsOpacity),
                    .action(action),
                ]
            )
        )
    }
}

// MARK: - Initializers With Bindings

// MARK: ColorWellView (Label: View)
@available(macOS 10.15, *)
extension ColorWellView {
    /// Creates a color well with a binding to a color value, with the
    /// provided view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - color: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    @available(macOS 11.0, *)
    public init(color: Binding<Color>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .colorBinding(color),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                ]
            )
        )
    }

    /// Creates a color well with a binding to a color value, with the
    /// provided view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - cgColor: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    public init(cgColor: Binding<CGColor>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColorBinding(cgColor),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                ]
            )
        )
    }
}

// MARK: ColorWellView (Label == Never)
@available(macOS 10.15, *)
extension ColorWellView where Label == Never {
    /// Creates a color well with a binding to a color value.
    ///
    /// - Parameters:
    ///   - color: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init(color: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .colorBinding(color),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    /// Creates a color well with a binding to a color value.
    ///
    /// - Parameters:
    ///   - cgColor: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init(cgColor: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColorBinding(cgColor),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }
}

// MARK: ColorWellView (Label == Text)
@available(macOS 10.15, *)
extension ColorWellView where Label == Text {

    // MARK: Generate Label From StringProtocol

    /// Creates a color well with a binding to a color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(_ title: S, color: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .colorBinding(color),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    /// Creates a color well with a binding to a color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init<S: StringProtocol>(_ title: S, cgColor: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColorBinding(cgColor),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    // MARK: Generate Label From LocalizedStringKey

    /// Creates a color well with a binding to a color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init(_ titleKey: LocalizedStringKey, color: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .colorBinding(color),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    /// Creates a color well with a binding to a color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init(_ titleKey: LocalizedStringKey, cgColor: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColorBinding(cgColor),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }
}
#endif
