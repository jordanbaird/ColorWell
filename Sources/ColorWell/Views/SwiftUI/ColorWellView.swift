//
// ColorWellView.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorWellView

/// A control that displays a user-selectable color value.
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
    /// color well.
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
    private init(configuration: ColorWellConfiguration) {
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
    /// Creates a color well that uses the provided view as its label,
    /// and executes the given action when its color changes.
    ///
    /// - Parameters:
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        @ViewBuilder label: () -> Label,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well that uses the provided view as its label,
    /// and executes the given action when its color changes.
    ///
    /// - Parameters:
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        showsAlpha: Binding<Bool>,
        @ViewBuilder label: () -> Label,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .showsAlpha(showsAlpha),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .label(label),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - color: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    @available(macOS 11.0, *)
    public init(
        showsAlpha: Binding<Bool>,
        color: Color,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .showsAlpha(showsAlpha),
                    .color(color),
                    .label(label),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    public init(
        cgColor: CGColor,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(cgColor),
                    .label(label),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    public init(
        showsAlpha: Binding<Bool>,
        cgColor: CGColor,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .showsAlpha(showsAlpha),
                    .color(cgColor),
                    .label(label),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided view
    /// being used as the color well's label, and the provided action being executed
    /// when the color well's color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        @ViewBuilder label: () -> Label,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided view
    /// being used as the color well's label, and the provided action being executed
    /// when the color well's color changes.
    ///
    /// - Parameters:
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - color: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        showsAlpha: Binding<Bool>,
        color: Color,
        @ViewBuilder label: () -> Label,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .showsAlpha(showsAlpha),
                    .color(color),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided view
    /// being used as the color well's label, and the provided action being executed
    /// when the color well's color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(color:label:action:)``.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        cgColor: CGColor,
        @ViewBuilder label: () -> Label,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(cgColor),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, with the provided view
    /// being used as the color well's label, and the provided action being executed
    /// when the color well's color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(showsAlpha:color:label:action:)``.
    ///
    /// - Parameters:
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        showsAlpha: Binding<Bool>,
        cgColor: CGColor,
        @ViewBuilder label: () -> Label,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .showsAlpha(showsAlpha),
                    .color(cgColor),
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
    /// Creates a color well with an initial color value.
    ///
    /// - Parameter color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init(color: Color) {
        self.init(configuration: ColorWellConfiguration(modifiers: [.color(color)]))
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .showsAlpha(showsAlpha),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameter cgColor: The initial value of the color well's color.
    public init(cgColor: CGColor) {
        self.init(configuration: ColorWellConfiguration(modifiers: [.color(cgColor)]))
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    public init(
        cgColor: CGColor,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(cgColor),
                    .showsAlpha(showsAlpha),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        color: Color,
        showsAlpha: Binding<Bool>,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(color),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(color:action:)``.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        cgColor: CGColor,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(cgColor),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(color:showsAlpha:action:)``.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        cgColor: CGColor,
        showsAlpha: Binding<Bool>,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .color(cgColor),
                    .showsAlpha(showsAlpha),
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

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        color: Color
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(color),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        color: Color,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(color),
                    .showsAlpha(showsAlpha),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(cgColor),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(cgColor),
                    .showsAlpha(showsAlpha),
                ]
            )
        )
    }

    /// Creates a color well that generates its label from a string, and
    /// performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(
        _ title: S,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well that generates its label from a string, and
    /// performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(
        _ title: S,
        showsAlpha: Binding<Bool>,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        color: Color,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(color),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        color: Color,
        showsAlpha: Binding<Bool>,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(color),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:action:)-8ghst``.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(cgColor),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:showsAlpha:action:)-68zal``.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        showsAlpha: Binding<Bool>,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .color(cgColor),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }

    // MARK: Generate Label From LocalizedStringKey

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        color: Color
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(color),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        color: Color,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(color),
                    .showsAlpha(showsAlpha),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(cgColor),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(cgColor),
                    .showsAlpha(showsAlpha),
                ]
            )
        )
    }

    /// Creates a color well that generates its label from a localized
    /// string key, and performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        _ titleKey: LocalizedStringKey,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well that generates its label from a localized
    /// string key, and performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        _ titleKey: LocalizedStringKey,
        showsAlpha: Binding<Bool>,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        color: Color,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(color),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        color: Color,
        showsAlpha: Binding<Bool>,
        action: @escaping (Color) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(color),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:action:)-3s0o1``.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(cgColor),
                    .action(action),
                ]
            )
        )
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:showsAlpha:action:)-60wmk``.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        showsAlpha: Binding<Bool>,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .color(cgColor),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }
}

// MARK: - View Modifiers

@available(macOS 10.15, *)
extension View {
    /// Adds an action to color wells within this view.
    ///
    /// - Parameter action: An action to perform when a color well's
    ///   color changes. The closure receives the new color as an input.
    public func onColorChange(perform action: @escaping (Color) -> Void) -> some View {
        transformEnvironment(\.changeHandlers) { changeHandlers in
            changeHandlers.append { color in
                action(Color(color))
            }
        }
    }

    /// Sets the style for color wells within this view.
    public func colorWellStyle<S: ColorWellStyle>(_ style: S) -> some View {
        transformEnvironment(\.colorWellStyleConfiguration) { configuration in
            configuration = style._configuration
        }
    }

    /// Applies the given swatch colors to the view's color wells.
    ///
    /// Swatches are user-selectable colors that are shown when
    /// a ``ColorWellView`` displays its popover.
    ///
    /// ![Default swatches](grid-view)
    ///
    /// Any color well that is part of the current view's hierarchy
    /// will update its swatches to the colors provided here.
    ///
    /// - Parameter colors: The swatch colors to use.
    @available(macOS 11.0, *)
    public func swatchColors(_ colors: [Color]) -> some View {
        transformEnvironment(\.swatchColors) { swatchColors in
            swatchColors = colors.map { NSColor($0) }
        }
    }
}
#endif
