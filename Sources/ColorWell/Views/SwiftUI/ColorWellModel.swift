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
    let color: NSColor?

    /// An optional action that is passed into the layout view and added
    /// to the color well.
    let action: ((NSColor) -> Void)?

    /// A closure that returns the value of a potential Boolean binding,
    /// to be accessed through the model's `showsAlpha` property.
    private let showsAlphaGetter: () -> Bool?

    /// A closure that updates the value of a potential Boolean binding,
    /// to be set through the model's `showsAlpha` property.
    private let showsAlphaSetter: (Bool?) -> Void

    /// An optional label that is displayed adjacent to the color well,
    /// represented as an existential type.
    private let _label: (any View)?

    /// An optional Boolean value indicating whether the color panel
    /// that belongs to the color well shows alpha values and an opacity
    /// slider.
    ///
    /// This property may be tied to an underlying binding. If this is
    /// the case, updating the property also updates the binding. If it
    /// is not tied to a binding, accessing this property will always
    /// return `nil`, and setting it will have no effect.
    var showsAlpha: Bool? {
        get { showsAlphaGetter() }
        set { showsAlphaSetter(newValue) }
    }

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
        typealias Values = (
            color: NSColor?,
            action: ((NSColor) -> Void)?,
            showsAlphaGetter: () -> Bool?,
            showsAlphaSetter: (Bool?) -> Void,
            label: (any View)?
        )

        var values: Values = (nil, nil, { nil }, { _ in }, nil)

        for modifier in modifiers {
            switch modifier {
            case .color(let color):
                values.color = color
            case .action(let action):
                values.action = action
            case .showsAlpha(let showsAlpha):
                guard let showsAlpha else {
                    values.showsAlphaGetter = { nil }
                    values.showsAlphaSetter = { _ in }
                    continue
                }
                values.showsAlphaGetter = { showsAlpha.wrappedValue }
                values.showsAlphaSetter = { newValue in
                    guard let newValue else {
                        return
                    }
                    showsAlpha.wrappedValue = newValue
                }
            case .label(let label):
                values.label = label
            }
        }

        self.color = values.color
        self.action = values.action
        self.showsAlphaGetter = values.showsAlphaGetter
        self.showsAlphaSetter = values.showsAlphaSetter
        self._label = values.label
    }
}

// MARK: - ColorWellModel Modifier

@available(macOS 10.15, *)
extension ColorWellModel {
    internal enum Modifier {
        /// Sets the model's color to the given value.
        case color(NSColor?)

        /// Sets the model's action to the given closure.
        case action(((NSColor) -> Void)?)

        /// Sets the model's `showsAlpha` binding to the given value.
        case showsAlpha(Binding<Bool>?)

        /// Sets the model's label to the given view.
        case label(any View)
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
}
#endif
