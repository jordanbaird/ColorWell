//
// ColorWellView.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorWellView

/// A SwiftUI view that displays a user-settable color value.
///
/// Color wells enable the user to select custom colors from within an app's
/// interface. A graphics app might, for example, include a color well to let
/// someone choose the fill color for a shape. Color wells display the currently
/// selected color, and interactions with the color well display interfaces
/// for selecting new colors.
@available(macOS 10.15, *)
public struct ColorWellView<Label: View>: View {
    private let content: AnyView

    /// The content view of the color well.
    public var body: some View {
        content
    }

    /// A base level initializer for other initializers to delegate to.
    ///
    /// ** For internal use only **
    private init<L: View, C: CustomCocoaConvertible>(
        _color: NSColor? = nil,
        _label: () -> L,
        _action: ((C) -> Void)? = Optional<(Color) -> Void>.none,
        _showsAlpha: Binding<Bool>? = nil
    ) where C.CocoaType == NSColor,
            C.Converted == C
    {
        content = LayoutView(
            Label.self,
            label: {
                _label()
            },
            content: {
                Representable(color: _color, showsAlpha: _showsAlpha)
                    .onColorChange(maybePerform: _action)
                    .fixedSize()
            }
        )
        .erased()
    }

    /// A base level initializer for other initializers to delegate to,
    /// whose `_label` parameter is an `@autoclosure`.
    ///
    /// ** For internal use only **
    private init<L: View, C: CustomCocoaConvertible>(
        _color: NSColor? = nil,
        _label: @autoclosure () -> L,
        _action: ((C) -> Void)? = Optional<(Color) -> Void>.none,
        _showsAlpha: Binding<Bool>? = nil
    ) where C.CocoaType == NSColor,
            C.Converted == C
    {
        self.init(
            _color: _color,
            _label: _label,
            _action: _action,
            _showsAlpha: _showsAlpha
        )
    }
}

// MARK: ColorWellView Initializers (Label: View)
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
            _label: label,
            _action: action
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
            _label: label,
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(color),
            _label: label
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
            _color: NSColor(color),
            _label: label,
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: label
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
            _color: NSColor(cgColor: cgColor),
            _label: label,
            _showsAlpha: showsAlpha
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
            _color: NSColor(color),
            _label: label,
            _action: action
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
            _color: NSColor(color),
            _label: label,
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: label,
            _action: action
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
            _color: NSColor(cgColor: cgColor),
            _label: label,
            _action: action,
            _showsAlpha: showsAlpha
        )
    }
}

// MARK: ColorWellView Initializers (Label == Never)
@available(macOS 10.15, *)
extension ColorWellView<Never> {
    /// Creates a color well with an initial color value.
    ///
    /// - Parameter color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init(color: Color) {
        self.init(
            _color: NSColor(color),
            _label: NoLabel()
        )
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
            _color: NSColor(color),
            _label: NoLabel(),
            _showsAlpha: showsAlpha
        )
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameter cgColor: The initial value of the color well's color.
    public init(cgColor: CGColor) {
        self.init(
            _color: NSColor(cgColor: cgColor),
            _label: NoLabel()
        )
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
            _color: NSColor(cgColor: cgColor),
            _label: NoLabel(),
            _showsAlpha: showsAlpha
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
            _color: NSColor(color),
            _label: NoLabel(),
            _action: action
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
            _color: NSColor(color),
            _label: NoLabel(),
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: NoLabel(),
            _action: action
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
            _color: NSColor(cgColor: cgColor),
            _label: NoLabel(),
            _action: action,
            _showsAlpha: showsAlpha
        )
    }
}

// MARK: ColorWellView Initializers (Label == Text)
@available(macOS 10.15, *)
extension ColorWellView<Text> {

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
            _color: NSColor(color),
            _label: Text(title)
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
            _color: NSColor(color),
            _label: Text(title),
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(title)
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(title),
            _showsAlpha: showsAlpha
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
            _label: Text(title),
            _action: action
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
            _label: Text(title),
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(color),
            _label: Text(title),
            _action: action
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
            _color: NSColor(color),
            _label: Text(title),
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(title),
            _action: action
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(title),
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(color),
            _label: Text(titleKey)
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
            _color: NSColor(color),
            _label: Text(titleKey),
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(titleKey)
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(titleKey),
            _showsAlpha: showsAlpha
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
            _label: Text(titleKey),
            _action: action
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
            _label: Text(titleKey),
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(color),
            _label: Text(titleKey),
            _action: action
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
            _color: NSColor(color),
            _label: Text(titleKey),
            _action: action,
            _showsAlpha: showsAlpha
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(titleKey),
            _action: action
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
            _color: NSColor(cgColor: cgColor),
            _label: Text(titleKey),
            _action: action,
            _showsAlpha: showsAlpha
        )
    }
}

// MARK: ColorWellView Representable
@available(macOS 10.15, *)
extension ColorWellView {
    /// An `NSViewRepresentable` wrapper around a `ColorWell`.
    ///
    /// ** For internal use only **
    private struct Representable: NSViewRepresentable {
        let color: NSColor?

        let showsAlphaIsEnabled: Bool

        @Binding var showsAlpha: Bool

        init(color: NSColor?, showsAlpha: Binding<Bool>?) {
            self.color = color
            if let showsAlpha {
                self.showsAlphaIsEnabled = true
                self._showsAlpha = showsAlpha
            } else {
                self.showsAlphaIsEnabled = false
                self._showsAlpha = .constant(true)
            }
        }

        func makeNSView(context: Context) -> ColorWell {
            if let color {
                return ColorWell(color: color)
            } else {
                return ColorWell()
            }
        }

        func updateNSView(_ nsView: ColorWell, context: Context) {
            nsView.changeHandlers.appendUnique(contentsOf: changeHandlers(for: context))
            nsView.isEnabled = context.environment.isEnabled

            if showsAlphaIsEnabled {
                nsView.showsAlpha = showsAlpha
            }

            if
                #available(macOS 11.0, *),
                let swatchColors = context.environment.swatchColors
            {
                nsView.swatchColors = swatchColors
            }
        }

        /// Returns the change handlers for the given context.
        func changeHandlers(for context: Context) -> [IdentifiableAction<NSColor>] {
            // Reversed to reflect the true order in which they were added.
            context.environment.changeHandlers.reversed()
        }
    }
}

// MARK: - NoLabel

/// A special view type whose presence indicates that a `ColorWellView`'s
/// constructor should not modify the constructed view to include a label.
///
/// ** For internal use only **
@available(macOS 10.15, *)
private struct NoLabel: View {
    var body: Never { return fatalError() }
}

// MARK: - LayoutView

/// A view that manages the layout of a `ColorWellView` and its label.
///
/// Its initializer takes a label candidate and content view. It validates
/// the label candidate's type to ensure that it meets the criteria to be
/// included as part of the constructed view. If the candidate fails
/// validation, only the content view will be included.
///
/// ** For internal use only **
@available(macOS 10.15, *)
private struct LayoutView<Label: View, LabelCandidate: View, Content: View>: View {
    private let erasedContent: AnyView

    var body: some View {
        erasedContent
    }

    init(
        _: Label.Type,
        @ViewBuilder label: () -> LabelCandidate,
        @ViewBuilder content: () -> Content
    ) {
        guard
            LabelCandidate.self == Label.self,
            Label.self != NoLabel.self
        else {
            erasedContent = content().erased()
            return
        }
        erasedContent = HStack(alignment: .center) {
            label()
            content()
        }
        .erased()
    }
}

// MARK: - ChangeHandlersKey

@available(macOS 10.15, *)
private struct ChangeHandlersKey: EnvironmentKey {
    static let defaultValue = [IdentifiableAction<NSColor>]()
}

// MARK: - SwatchColorsKey

@available(macOS 11.0, *)
private struct SwatchColorsKey: EnvironmentKey {
    static let defaultValue: [NSColor]? = nil
}

// MARK: - EnvironmentValues Change Handlers

@available(macOS 10.15, *)
extension EnvironmentValues {
    internal var changeHandlers: [IdentifiableAction<NSColor>] {
        get { self[ChangeHandlersKey.self] }
        set { self[ChangeHandlersKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues Swatch Colors

@available(macOS 11.0, *)
extension EnvironmentValues {
    internal var swatchColors: [NSColor]? {
        get { self[SwatchColorsKey.self] }
        set { self[SwatchColorsKey.self] = newValue }
    }
}

// MARK: - OnColorChange

@available(macOS 10.15, *)
private struct OnColorChange<C: CustomCocoaConvertible>: ViewModifier
    where C.CocoaType == NSColor,
          C.Converted == C
{
    let id = UUID()
    let action: ((C) -> Void)?

    func body(content: Content) -> some View {
        content.transformEnvironment(\.changeHandlers) { changeHandlers in
            let changeHandler = action.map { action in
                IdentifiableAction(id: id) { color in
                    action(.converted(from: color))
                }
            }
            if let changeHandler {
                changeHandlers.appendUnique(changeHandler)
            }
        }
    }
}

// MARK: - View On Color Change

@available(macOS 10.15, *)
extension View {
    /// Adds a generic action to perform when a color well's color changes.
    ///
    /// ** For internal use only **
    fileprivate func onColorChange<C: CustomCocoaConvertible>(maybePerform action: ((C) -> Void)?) -> some View
        where C.CocoaType == NSColor,
              C.Converted == C
    {
        modifier(OnColorChange(action: action))
    }

    /// Adds an action to perform when a color well's color changes.
    ///
    /// The following example creates a `VStack` containing a text view
    /// and a color well, both of which utilize the same `@State` value
    /// during their construction. The `onColorChange(perform:)` modifier
    /// is applied to the color well. Every time the user selects a new
    /// color using the color well, the `@State` value is updated to match
    /// the new color. This causes the text view to be redrawn to match
    /// the new state.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var color = Color.green
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Text("Colored Text")
    ///                 .foregroundColor(color)
    ///
    ///             ColorWellView(color: color)
    ///                 .onColorChange { newColor in
    ///                     self.color = newColor
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Let's say we have a view with multiple color wells, and simply
    /// want to log the new color when any of their colors change. We can
    /// do so like this:
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         VStack {
    ///             ColorWellView(color: .red)
    ///             ColorWellView(color: .green)
    ///             ColorWellView(color: .blue)
    ///         }
    ///         .onColorChange { newColor in
    ///             print(newColor)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter action: An action to perform when a color well's color changes.
    public func onColorChange(perform action: @escaping (Color) -> Void) -> some View {
        onColorChange(maybePerform: action)
    }
}

// MARK: - View Swatch Colors

@available(macOS 11.0, *)
extension View {
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
    public func swatchColors(_ colors: [Color]) -> some View {
        environment(\.swatchColors, colors.map { NSColor($0) })
    }
}
#endif
