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
internal struct ColorWellViewModel {

    // MARK: Properties

    /// The color well's color.
    let color: NSColor?

    /// An object that validates the type of the model's `label`
    /// property.
    let validator: LabelValidator

    /// An optional action that is passed into the layout view to
    /// add to the color well.
    let action: ((NSColor) -> Void)?

    /// A binding to a Boolean value indicating whether the color
    /// panel that belongs to the color well shows alpha values
    /// and an opacity slider.
    let showsAlpha: Binding<Bool>?

    /// An optional label that is displayed adjacent to the color
    /// well.
    ///
    /// As there are many different types that can be used to create
    /// the label, its type is validated by the model's `validator`
    /// to determine whether it is a valid type for display.
    var label: (some View)? {
        validator.label
    }

    /// A view that manages the layout of the color well.
    var content: some View {
        ColorWellViewLayout(model: self)
    }

    // MARK: Initializers

    /// Creates a model with the given values.
    init(
        color: NSColor?,
        validator: LabelValidator,
        action: ((NSColor) -> Void)?,
        showsAlpha: Binding<Bool>?
    ) {
        self.color = color
        self.validator = validator
        self.action = action
        self.showsAlpha = showsAlpha
    }

    /// Creates a model with the default values.
    init() {
        self.init(
            color: nil,
            validator: .invalid,
            action: nil,
            showsAlpha: nil
        )
    }

    /// Creates a model with the given label type and label candidate.
    ///
    /// The label will be validated before being displayed. If it fails
    /// validation, only the color well's content view will be shown.
    init<Label: View, LabelCandidate: View>(_: Label.Type, label: () -> LabelCandidate) {
        self.init(
            color: nil,
            validator: LabelValidator(Label.self, label: label),
            action: nil,
            showsAlpha: nil
        )
    }

    /// Creates a model with the given label type and label candidate.
    ///
    /// The label will be validated before being displayed. If it fails
    /// validation, only the color well's content view will be shown.
    init<Label: View, LabelCandidate: View>(_: Label.Type, label: @autoclosure () -> LabelCandidate) {
        self.init(Label.self, label: label)
    }

    /// Creates a model with the given label.
    ///
    /// The label will be validated before being displayed. If it fails
    /// validation, only the color well's content view will be shown.
    init<Label: View>(label: () -> Label) {
        self.init(Label.self, label: label)
    }

    /// Creates a model with the given label.
    ///
    /// The label will be validated before being displayed. If it fails
    /// validation, only the color well's content view will be shown.
    init<Label: View>(label: @autoclosure () -> Label) {
        self.init(label: label)
    }

    // MARK: Modifiers

    /// Returns a new model with the given color.
    func color(_ color: NSColor?) -> Self {
        Self(
            color: color,
            validator: validator,
            action: action,
            showsAlpha: showsAlpha
        )
    }

    /// Returns a new model with the given color.
    @available(macOS 11.0, *)
    func color(_ color: Color?) -> Self {
        self.color(color.map(NSColor.init))
    }

    /// Returns a new model with the given color.
    func color(_ color: CGColor?) -> Self {
        self.color(color.flatMap(NSColor.init))
    }

    /// Returns a new model with the given label validator.
    func validator(_ validator: LabelValidator) -> Self {
        Self(
            color: color,
            validator: validator,
            action: action,
            showsAlpha: showsAlpha
        )
    }

    /// Returns a new model with the given action.
    func action(_ action: ((NSColor) -> Void)?) -> Self {
        Self(
            color: color,
            validator: validator,
            action: action,
            showsAlpha: showsAlpha
        )
    }

    /// Returns a new model with the given action.
    func action(_ action: ((Color) -> Void)?) -> Self {
        self.action(action.map { action in
            let converted: (NSColor) -> Void = { color in
                action(Color(color))
            }
            return converted
        })
    }

    /// Returns a new model with the given action.
    func action(_ action: ((CGColor) -> Void)?) -> Self {
        self.action(action.map { action in
            let converted: (NSColor) -> Void = { color in
                action(color.cgColor)
            }
            return converted
        })
    }

    /// Returns a new model with the given `showsAlpha` binding.
    func showsAlpha(_ showsAlpha: Binding<Bool>?) -> Self {
        Self(
            color: color,
            validator: validator,
            action: action,
            showsAlpha: showsAlpha
        )
    }
}

// MARK: - LabelValidator

@available(macOS 10.15, *)
internal struct LabelValidator {
    /// A closure that produces the pre-validated label.
    private let _label: (() -> any View)?

    /// The label validated by this instance.
    var label: (some View)? { _label?().erased() }

    /// Creates a label validator for the given label type and
    /// label candidate.
    init<Label: View, LabelCandidate: View>(_: Label.Type, label: () -> LabelCandidate) {
        if LabelCandidate.self == Label.self {
            _label = label().opaque
        } else {
            _label = nil
        }
    }

    /// Creates a label validator for the given label type and
    /// label candidate.
    init<Label: View, LabelCandidate: View>(_: Label.Type, label: @autoclosure () -> LabelCandidate) {
        self.init(Label.self, label: label)
    }

    /// Creates label validator that unconditionally invalidates
    /// its label.
    init(invalid: ()) { _label = nil }
}

@available(macOS 10.15, *)
extension LabelValidator {
    /// A label validator that unconditionally invalidates its
    /// label.
    static var invalid: Self {
        LabelValidator(invalid: ())
    }
}
#endif
