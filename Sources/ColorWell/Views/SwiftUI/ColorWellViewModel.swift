//
// ColorWellViewModel.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorWellViewModel

/// A type containing information used to construct a color well.
@available(macOS 10.15, *)
internal class ColorWellViewModel {

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

    /// A view that manages the layout of the color well.
    var content: some View {
        ColorWellViewLayout(model: self)
    }

    // MARK: Initializers

    /// Creates a model with the given values.
    init(
        color: NSColor?,
        label: (some View)?,
        action: ((NSColor) -> Void)?,
        showsAlpha: Binding<Bool>?
    ) {
        self.color = color
        self._label = label
        self.action = action
        self.showsAlpha = showsAlpha
    }

    /// Creates a model with the default values.
    convenience init() {
        self.init(
            color: nil,
            label: .invalid,
            action: nil,
            showsAlpha: nil
        )
    }

    // MARK: Methods

    /// Returns the optional value at the given keypath, removing
    /// its value from the model after the value is returned.
    func take<Value>(_ keyPath: KeyPath<ColorWellViewModel, Value?>) -> Value? {
        defer {
            if let keyPath = keyPath as? ReferenceWritableKeyPath<ColorWellViewModel, Value?> {
                self[keyPath: keyPath] = nil
            }
        }
        return self[keyPath: keyPath]
    }

    // MARK: Modifiers

    /// Sets the model's color to the given value.
    func color(_ color: NSColor?) -> Self {
        self.color = color
        return self
    }

    /// Sets the model's color to the given value.
    @available(macOS 11.0, *)
    func color(_ color: Color?) -> Self {
        self.color(color.map(NSColor.init))
    }

    /// Sets the model's color to the given value.
    func color(_ color: CGColor?) -> Self {
        self.color(color.flatMap(NSColor.init))
    }

    /// Sets the model's label to the given value.
    func label(_ label: some View) -> Self {
        self._label = label
        return self
    }

    /// Sets the model's action to the given value.
    func action(_ action: ((NSColor) -> Void)?) -> Self {
        self.action = action
        return self
    }

    /// Sets the model's action to the given value.
    func action(_ action: ((Color) -> Void)?) -> Self {
        self.action(action.map { action in
            let converted: (NSColor) -> Void = { color in
                action(Color(color))
            }
            return converted
        })
    }

    /// Sets the model's action to the given value.
    func action(_ action: ((CGColor) -> Void)?) -> Self {
        self.action(action.map { action in
            let converted: (NSColor) -> Void = { color in
                action(color.cgColor)
            }
            return converted
        })
    }

    /// Sets the model's `showsAlpha` binding to the given value.
    func showsAlpha(_ showsAlpha: Binding<Bool>?) -> Self {
        self.showsAlpha = showsAlpha
        return self
    }
}

// MARK: - ColorWellViewModel InvalidLabel

@available(macOS 10.15, *)
extension ColorWellViewModel {
    /// A type that represents an invalid label that should never be displayed.
    internal enum _InvalidLabel: View {
        var body: some View { return self }
    }

    /// A placeholder type for an invalid label that should never be displayed.
    internal typealias InvalidLabel = _InvalidLabel?
}

@available(macOS 10.15, *)
extension ColorWellViewModel.InvalidLabel {
    /// A placeholder for an invalid label that should never be displayed.
    internal static var invalid: Self { .none }
}
#endif
