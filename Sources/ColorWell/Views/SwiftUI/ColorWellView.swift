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

    // MARK: Instance Properties

    /// The type-erased layout view of the color well.
    private let layoutView: AnyView

    /// The content view of the color well.
    public var body: some View { layoutView }

    // MARK: Initializers

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
        layoutView = LayoutView(
            Label.self,
            label: {
                _label()
            },
            content: {
                Representable(color: _color, showsAlpha: _showsAlpha)
                    .onColorChange(maybePerform: _action)
                    .fixedSize()
            }
        ).erased()
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

// MARK: ColorWellView (Label == Never)
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

// MARK: ColorWellView (Label == Text)
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

// MARK: - ColorWellView Representable

@available(macOS 10.15, *)
extension ColorWellView {
    /// An `NSViewRepresentable` wrapper around a `ColorWell`.
    ///
    /// ** For internal use only **
    private struct Representable: NSViewRepresentable {

        // MARK: Instance Properties

        /// The color used to create this view's underlying color well.
        let color: NSColor?

        /// A Boolean value that indicates whether the this view should
        /// update its underlying color well's `showsAlpha` property whenever
        /// the view itself updates.
        let shouldUpdateShowsAlpha: Bool

        /// A binding to a Boolean value indicating whether the color panel
        /// that belongs to this view's underlying color well shows alpha
        /// values and an opacity slider.
        @Binding var showsAlpha: Bool

        // MARK: Initializers

        /// Creates a representable view with the given color, and an
        /// optional binding that determines the value of the underlying
        /// color well's `showsAlpha` property.
        init(color: NSColor?, showsAlpha: Binding<Bool>?) {
            self.color = color
            if let showsAlpha {
                self.shouldUpdateShowsAlpha = true
                self._showsAlpha = showsAlpha
            } else {
                self.shouldUpdateShowsAlpha = false
                self._showsAlpha = .constant(true)
            }
        }

        // MARK: Instance Methods

        /// Creates and returns this view's underlying color well.
        func makeNSView(context: Context) -> ColorWell {
            if let color {
                return ColorWell(color: color)
            } else {
                return ColorWell()
            }
        }

        /// Updates this view's underlying color well using the specified
        /// context.
        func updateNSView(_ nsView: ColorWell, context: Context) {
            nsView.changeHandlers.appendUnique(contentsOf: changeHandlers(for: context))
            nsView.isEnabled = context.environment.isEnabled

            if shouldUpdateShowsAlpha {
                nsView.showsAlpha = showsAlpha
            }

            if
                #available(macOS 11.0, *),
                let swatchColors = context.environment.swatchColors
            {
                nsView.swatchColors = swatchColors
            }
        }

        /// Returns the change handlers stored in the view's environment for
        /// the specified context.
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
    /// Accessing this property results in a fatal error.
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
    /// The type-erased content of the layout view.
    private let erasedContent: AnyView

    /// The layout view's content view.
    var body: some View { erasedContent }

    /// Creates a layout view that validates the given label candidate's
    /// type to ensure that it meets the criteria to be included as part
    /// of the constructed view.
    ///
    /// If the candidate fails validation, only the content view will be
    /// included in the final constructed view.
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
        }.erased()
    }
}

// MARK: - ChangeHandlersKey

/// A key used to store a color well's change handlers in an environment.
@available(macOS 10.15, *)
private struct ChangeHandlersKey: EnvironmentKey {
    static let defaultValue = [IdentifiableAction<NSColor>]()
}

// MARK: - SwatchColorsKey

/// A key used to store a color well's swatch colors in an environment.
@available(macOS 11.0, *)
private struct SwatchColorsKey: EnvironmentKey {
    static let defaultValue: [NSColor]? = nil
}

// MARK: - EnvironmentValues Change Handlers

@available(macOS 10.15, *)
extension EnvironmentValues {
    /// The change handlers to add to the color wells in this environment.
    internal var changeHandlers: [IdentifiableAction<NSColor>] {
        get { self[ChangeHandlersKey.self] }
        set { self[ChangeHandlersKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues Swatch Colors

@available(macOS 11.0, *)
extension EnvironmentValues {
    /// The swatch colors to apply to the color wells in this environment.
    internal var swatchColors: [NSColor]? {
        get { self[SwatchColorsKey.self] }
        set { self[SwatchColorsKey.self] = newValue }
    }
}

// MARK: - OnColorChange

/// A view modifier that performs an action when a color well's
/// color changes.
///
/// This modifier is designed so that any type that conforms
/// to the `CustomCocoaConvertible` protocol and converts to
/// an `NSColor` can be used to create its change handler.
@available(macOS 10.15, *)
private struct OnColorChange<C: CustomCocoaConvertible>: ViewModifier
    where C.CocoaType == NSColor,
          C.Converted == C
{
    /// A unique identifier used to create this modifier's change handler.
    let id = UUID()

    /// A closure used to create this modifier's change handler. It takes
    /// a generic `CustomCocoaConvertible` type that converts to an `NSColor`.
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

    /// Adds an action to color wells within this view.
    ///
    /// - Parameter action: An action to perform when a color well's
    ///   color changes. The closure receives the new color as an input.
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
