//
// Deprecated.swift
// ColorWell
//

import Cocoa

// MARK: - ColorWell

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

// MARK: - ColorWellView

// MARK: ColorWellView where Label: View
@available(macOS 10.15, *)
extension ColorWellView {
    /// Creates a color well that uses the provided view as its label,
    /// and executes the given action when its color changes.
    ///
    /// - Parameters:
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:label:)", message: "Use 'init(selection:supportsOpacity:label:)' instead.")
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

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:label:)", message: "Use 'init(selection:supportsOpacity:label:)' instead.")
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

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:label:)", message: "Use 'init(selection:supportsOpacity:label:)' instead.")
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
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:label:)", message: "Use 'init(selection:supportsOpacity:label:)' instead.")
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
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:label:)", message: "Use 'init(selection:supportsOpacity:label:)' instead.")
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

// MARK: ColorWellView where Label == Never
@available(macOS 10.15, *)
extension ColorWellView where Label == Never {
    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:)", message: "Use 'init(selection:supportsOpacity:)' instead.")
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

    /// Creates a color well with an initial color value.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:)", message: "Use 'init(selection:supportsOpacity:)' instead.")
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

    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:)", message: "Use 'init(selection:supportsOpacity:)' instead.")
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
    @available(*, deprecated, renamed: "init(selection:supportsOpacity:)", message: "Use 'init(selection:supportsOpacity:)' instead.")
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

// MARK: ColorWellView where Label == Text
@available(macOS 10.15, *)
extension ColorWellView where Label == Text {

    // MARK: Generate Label From StringProtocol

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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

    /// Creates a color well that generates its label from a string, and
    /// performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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

    /// Creates a color well that generates its label from a localized
    /// string key, and performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - action: An action to perform when the color well's color changes.
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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
    @available(*, deprecated, renamed: "init(_:selection:supportsOpacity:)", message: "Use 'init(_:selection:supportsOpacity:)' instead.")
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

@available(*, deprecated, message: "Actions are no longer supported. Use a Binding instead.")
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
}
#endif
