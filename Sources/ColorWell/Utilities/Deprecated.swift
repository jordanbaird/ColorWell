//
// Deprecated.swift
// ColorWell
//

import Cocoa

extension ColorWell {
    /// The color panel associated with the color well.
    @available(*, deprecated, message: "'colorPanel' is no longer used and will be removed in a future release. Use 'NSColorPanel.shared' instead.")
    public var colorPanel: NSColorPanel { .shared }

    /// A Boolean value indicating whether the color panel associated
    /// with the color well shows alpha values and an opacity slider.
    @available(*, deprecated, message: "Use 'NSColorPanel.shared.showsAlpha' instead.")
    @objc dynamic
    public var showsAlpha: Bool {
        get { NSColorPanel.shared.showsAlpha }
        set { NSColorPanel.shared.showsAlpha = newValue }
    }

    /// Creates a color well with the specified Core Image color.
    ///
    /// - Parameter ciColor: The initial value of the color well's color.
    @available(*, deprecated, renamed: "init(coreImageColor:)", message: "This initializer can result in unexpected runtime behavior. Use the failable 'init(coreImageColor:)' instead.")
    public convenience init(ciColor: CIColor) {
        self.init(color: NSColor(ciColor: ciColor))
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
extension ColorWellView {
    /// Creates a color well that uses the provided view as its label,
    /// and executes the given action when its color changes.
    ///
    /// - Parameters:
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(supportsOpacity:label:action:)' instead.")
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(supportsOpacity:label:action:)' instead.")
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:label:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:label:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:label:)' instead.")
    @_disfavoredOverload
    public init(
        cgColor: CGColor,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:label:)' instead.")
    @_disfavoredOverload
    public init(
        showsAlpha: Binding<Bool>,
        cgColor: CGColor,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .showsAlpha(showsAlpha),
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:label:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:label:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    ///   color well's underlying representation, use `init(color:label:action:)`.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:label:action:)' instead.")
    @_disfavoredOverload
    public init(
        cgColor: CGColor,
        @ViewBuilder label: () -> Label,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
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
    ///   color well's underlying representation, use `init(showsAlpha:color:label:action:)`.
    ///
    /// - Parameters:
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:label:action:)' instead.")
    @_disfavoredOverload
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
                    .cgColor(cgColor),
                    .label(label),
                    .action(action),
                ]
            )
        )
    }
}

@available(macOS 10.15, *)
extension ColorWellView where Label == Never {
    /// Creates a color well with an initial color value.
    ///
    /// - Parameter color: The initial value of the color well's color.
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
    public init(color: Color) {
        self.init(configuration: ColorWellConfiguration(modifiers: [.color(color)]))
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:)' instead.")
    @_disfavoredOverload
    public init(cgColor: CGColor) {
        self.init(configuration: ColorWellConfiguration(modifiers: [.cgColor(cgColor)]))
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:)' instead.")
    @_disfavoredOverload
    public init(
        cgColor: CGColor,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(color:supportsOpacity:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    ///   color well's underlying representation, use `init(color:action:)`.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
    public init(
        cgColor: CGColor,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
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
    ///   color well's underlying representation, use `init(color:showsAlpha:action:)`.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(cgColor:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
    public init(
        cgColor: CGColor,
        showsAlpha: Binding<Bool>,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColor(cgColor),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }
}

@available(macOS 10.15, *)
extension ColorWellView where Label == Text {
    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:)' instead.")
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:)' instead.")
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(_:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    ///   color well's underlying representation, use `init(_:color:action:)`.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        cgColor: CGColor,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColor(cgColor),
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
    ///   color well's underlying representation, use `init(_:color:showsAlpha:action:)`.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
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
                    .cgColor(cgColor),
                    .showsAlpha(showsAlpha),
                    .action(action),
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:)' instead.")
    @_disfavoredOverload
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:)' instead.")
    @_disfavoredOverload
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        showsAlpha: Binding<Bool>
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColor(cgColor),
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
    @available(*, deprecated, message: "Use 'init(_:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    @available(*, deprecated, message: "Use 'init(_:color:supportsOpacity:action:)' instead.")
    @available(macOS 11.0, *)
    @_disfavoredOverload
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
    ///   color well's underlying representation, use `init(_:color:action:)`.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
    public init(
        _ titleKey: LocalizedStringKey,
        cgColor: CGColor,
        action: @escaping (CGColor) -> Void
    ) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColor(cgColor),
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
    ///   color well's underlying representation, use `init(_:color:showsAlpha:action:)`.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - showsAlpha: A binding to a Boolean value indicating whether the
    ///     color well's color panel shows alpha values and an opacity slider.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, message: "Use 'init(_:cgColor:supportsOpacity:action:)' instead.")
    @_disfavoredOverload
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
                    .cgColor(cgColor),
                    .showsAlpha(showsAlpha),
                    .action(action),
                ]
            )
        )
    }
}

// MARK: - PanelColorWellStyle

/// A color well style that displays the color well's color inside of a
/// rectangular control, and toggles the system color panel when clicked.
///
/// You can also use ``colorPanel`` to construct this style.
@available(*, deprecated, renamed: "StandardColorWellStyle", message: "replaced by 'StandardColorWellStyle'")
public struct PanelColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .colorPanel)

    /// Creates an instance of the color panel color well style.
    public init() { }
}

@available(*, deprecated, renamed: "StandardColorWellStyle", message: "replaced by 'StandardColorWellStyle'")
extension ColorWellStyle where Self == PanelColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and toggles the system color panel when clicked.
    @available(*, deprecated, renamed: "standard", message: "replaced by 'standard'")
    public static var colorPanel: PanelColorWellStyle {
        PanelColorWellStyle()
    }
}
#endif
