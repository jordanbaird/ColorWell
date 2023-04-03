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

// MARK: ColorWellView where Label: View
@available(macOS 10.15, *)
extension ColorWellView {
    /// Creates a color well with a binding to a color value, with the
    /// provided view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    @available(macOS 11.0, *)
    public init(selection: Binding<Color>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .colorBinding(selection),
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
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    ///   - label: A view that describes the purpose of the color well.
    public init(selection: Binding<CGColor>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColorBinding(selection),
                    .supportsOpacity(supportsOpacity),
                    .label(label),
                ]
            )
        )
    }
}

// MARK: ColorWellView where Label == Never
@available(macOS 10.15, *)
extension ColorWellView where Label == Never {
    /// Creates a color well with a binding to a color value.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init(selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .colorBinding(selection),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }

    /// Creates a color well with a binding to a color value.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init(selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .cgColorBinding(selection),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }
}

// MARK: ColorWellView where Label == Text
@available(macOS 10.15, *)
extension ColorWellView where Label == Text {

    // MARK: Generate Label From StringProtocol

    /// Creates a color well with a binding to a color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(_ title: S, selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .colorBinding(selection),
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
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init<S: StringProtocol>(_ title: S, selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .title(title),
                    .cgColorBinding(selection),
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
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    @available(macOS 11.0, *)
    public init(_ titleKey: LocalizedStringKey, selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .colorBinding(selection),
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
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether
    ///     the color well allows adjusting the selected color's opacity;
    ///     the default is true.
    public init(_ titleKey: LocalizedStringKey, selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            configuration: ColorWellConfiguration(
                modifiers: [
                    .titleKey(titleKey),
                    .cgColorBinding(selection),
                    .supportsOpacity(supportsOpacity),
                ]
            )
        )
    }
}
#endif
