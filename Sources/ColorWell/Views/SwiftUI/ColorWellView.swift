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

    /// The model used to construct the color well.
    private let model: ColorWellViewModel

    /// The content view of the color well.
    public var body: some View {
        model.content
    }

    // MARK: Initializers

    /// A base level initializer for other initializers to delegate to.
    ///
    /// ** For internal use only **
    private init(model: ColorWellViewModel) {
        self.model = model
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
            model: ColorWellViewModel(label: label)
                .action(action)
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
            model: ColorWellViewModel(label: label)
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: label)
                .color(color)
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
            model: ColorWellViewModel(label: label)
                .showsAlpha(showsAlpha)
                .color(color)
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
            model: ColorWellViewModel(label: label)
                .color(cgColor)
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
            model: ColorWellViewModel(label: label)
                .showsAlpha(showsAlpha)
                .color(cgColor)
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
            model: ColorWellViewModel(label: label)
                .color(color)
                .action(action)
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
            model: ColorWellViewModel(label: label)
                .showsAlpha(showsAlpha)
                .color(color)
                .action(action)
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
            model: ColorWellViewModel(label: label)
                .color(cgColor)
                .action(action)
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
            model: ColorWellViewModel(label: label)
                .showsAlpha(showsAlpha)
                .color(cgColor)
                .action(action)
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
        self.init(
            model: ColorWellViewModel()
                .color(color)
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
            model: ColorWellViewModel()
                .color(color)
                .showsAlpha(showsAlpha)
        )
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameter cgColor: The initial value of the color well's color.
    public init(cgColor: CGColor) {
        self.init(
            model: ColorWellViewModel()
                .color(cgColor)
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
            model: ColorWellViewModel()
                .color(cgColor)
                .showsAlpha(showsAlpha)
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
            model: ColorWellViewModel()
                .color(color)
                .action(action)
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
            model: ColorWellViewModel()
                .color(color)
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel()
                .color(cgColor)
                .action(action)
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
            model: ColorWellViewModel()
                .color(cgColor)
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: Text(title))
                .color(color)
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
            model: ColorWellViewModel(label: Text(title))
                .color(color)
                .showsAlpha(showsAlpha)
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
            model: ColorWellViewModel(label: Text(title))
                .color(cgColor)
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
            model: ColorWellViewModel(label: Text(title))
                .color(cgColor)
                .showsAlpha(showsAlpha)
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
            model: ColorWellViewModel(label: Text(title))
                .action(action)
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
            model: ColorWellViewModel(label: Text(title))
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: Text(title))
                .color(color)
                .action(action)
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
            model: ColorWellViewModel(label: Text(title))
                .color(color)
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: Text(title))
                .color(cgColor)
                .action(action)
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
            model: ColorWellViewModel(label: Text(title))
                .color(cgColor)
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(color)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(color)
                .showsAlpha(showsAlpha)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(cgColor)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(cgColor)
                .showsAlpha(showsAlpha)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .action(action)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(color)
                .action(action)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(color)
                .showsAlpha(showsAlpha)
                .action(action)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(cgColor)
                .action(action)
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
            model: ColorWellViewModel(label: Text(titleKey))
                .color(cgColor)
                .showsAlpha(showsAlpha)
                .action(action)
        )
    }
}

// MARK: - View Extension

@available(macOS 10.15, *)
extension View {
    /// Adds an action to color wells within this view.
    ///
    /// ** For internal use only **
    internal func onColorChange(maybePerform action: ((NSColor) -> Void)?) -> some View {
        transformEnvironment(\.changeHandlers) { changeHandlers in
            guard let action else {
                return
            }
            changeHandlers.append(action)
        }
    }

    /// Adds an action to color wells within this view.
    ///
    /// - Parameter action: An action to perform when a color well's
    ///   color changes. The closure receives the new color as an input.
    public func onColorChange(perform action: @escaping (Color) -> Void) -> some View {
        onColorChange(maybePerform: passResult(of: Color.init, into: action))
    }

    /// Sets the style for color wells within this view.
    public func colorWellStyle<S: ColorWellStyle>(_ style: S) -> some View {
        transformEnvironment(\.colorWellStyleConfiguration) { configuration in
            configuration = style.configuration
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
