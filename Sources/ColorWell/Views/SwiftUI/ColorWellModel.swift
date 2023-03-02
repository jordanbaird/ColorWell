//
// ColorWellModel.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorWellModel

/// A type containing information used to construct a color well.
@available(macOS 10.15, *)
internal struct ColorWellModel {

    // MARK: Properties

    /// The color well's color.
    private(set) var color: NSColor?

    /// An optional action that is passed into the layout view and added
    /// to the color well.
    private(set) var action: ((NSColor) -> Void)?

    /// A binding to a Boolean value indicating whether the color panel
    /// that belongs to the color well shows alpha values and an opacity
    /// slider.
    private(set) var showsAlpha: Binding<Bool>?

    /// An optional label that is displayed adjacent to the color well,
    /// represented as an existential type.
    private var _label: (any View)?

    /// An optional label that is displayed adjacent to the color well.
    var label: (some View)? {
        _label?.erased()
    }

    /// An `NSViewRepresentable` wrapper around the color well.
    var representable: some View {
        ColorWellRepresentable(model: self).fixedSize()
    }

    // MARK: Initializers

    init(modifiers: [Modifier]) {
        for modifier in modifiers {
            switch modifier {
            case .color(let color):
                self.color = color
            case .label(let label):
                self._label = label
            case .action(let action):
                self.action = action
            case .showsAlpha(let showsAlpha):
                self.showsAlpha = showsAlpha
            }
        }
    }
}

// MARK: - ColorWellModel Modifier

@available(macOS 10.15, *)
extension ColorWellModel {
    internal enum Modifier {
        /// Sets the model's color to the given value.
        case color(NSColor?)

        /// Sets the model's label to the given view.
        case label(any View)

        /// Sets the model's action to the given closure.
        case action(((NSColor) -> Void)?)

        /// Sets the model's `showsAlpha` binding to the given value.
        case showsAlpha(Binding<Bool>?)
    }
}

// MARK: - Modifier Constructors

@available(macOS 10.15, *)
extension ColorWellModel.Modifier {
    /// Sets the model's color to the given value.
    @available(macOS 11.0, *)
    static func color(_ color: Color?) -> Self {
        Self.color(color.map(NSColor.init))
    }

    /// Sets the model's color to the given value.
    static func color(_ cgColor: CGColor?) -> Self {
        Self.color(cgColor.flatMap(NSColor.init))
    }

    /// Sets the model's label to the view returned from the given closure.
    static func label(_ label: () -> any View) -> Self {
        Self.label(label())
    }

    /// Sets the model's label to a text view constructed using
    /// the given string.
    static func title<S: StringProtocol>(_ title: S) -> Self {
        Self.label(Text(title))
    }

    /// Sets the model's label to a text view constructed using
    /// the given localized string key.
    static func titleKey(_ titleKey: LocalizedStringKey) -> Self {
        Self.label(Text(titleKey))
    }

    /// Sets the model's action to the given closure.
    static func action(_ action: ((Color) -> Void)?) -> Self {
        Self.action(action.map { action in
            let converted: (NSColor) -> Void = { color in
                action(Color(color))
            }
            return converted
        })
    }

    /// Sets the model's action to the given closure.
    static func action(_ action: ((CGColor) -> Void)?) -> Self {
        Self.action(action.map { action in
            let converted: (NSColor) -> Void = { color in
                action(color.cgColor)
            }
            return converted
        })
    }
}

// MARK: - ColorWellModel InvalidLabel

@available(macOS 10.15, *)
extension ColorWellModel {
    /// A type that represents an invalid label that should never be displayed.
    internal enum _InvalidLabel: View {
        var body: some View { return self }
    }

    /// A placeholder type for an invalid label that should never be displayed.
    internal typealias InvalidLabel = _InvalidLabel?
}

@available(macOS 10.15, *)
extension ColorWellModel.InvalidLabel {
    /// A placeholder for an invalid label that should never be displayed.
    internal static var invalid: Self { .none }
}
#endif
