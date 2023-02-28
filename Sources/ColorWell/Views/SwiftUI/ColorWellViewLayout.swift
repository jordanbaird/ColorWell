//
// ColorWellViewLayout.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorWellViewLayout

/// A view that manages the layout of a `ColorWellView` and its label.
///
/// Its initializer takes a label candidate and content view. It validates
/// the label candidate's type to ensure that it meets the criteria to be
/// included as part of the constructed view. If the candidate fails
/// validation, only the content view will be included.
///
/// ** For internal use only **
@available(macOS 10.15, *)
internal struct ColorWellViewLayout<Label: View, LabelCandidate: View>: View {
    /// The values used to construct the layout view.
    let values: ColorWellViewValues<Label, LabelCandidate>

    /// The layout view's optional label builder.
    var label: (() -> LabelCandidate)? {
        if
            LabelCandidate.self == Label.self,
            Label.self != NoLabel.self
        {
            return values.label
        } else {
            return nil
        }
    }

    /// The layout view's content view.
    var content: some View {
        ColorWellRepresentable(color: values.color, showsAlpha: values.showsAlpha)
            .onColorChange(maybePerform: values.action)
            .fixedSize()
    }

    /// The body of the layout view.
    var body: some View {
        if let label {
            HStack(alignment: .center) {
                label()
                content
            }
        } else {
            content
        }
    }

    /// Creates a layout view that validates the given label candidate's
    /// type to ensure that it meets the criteria to be included as part
    /// of the constructed view.
    ///
    /// If the candidate fails validation, only the content view will be
    /// included in the final constructed view.
    init(values: ColorWellViewValues<Label, LabelCandidate>) {
        self.values = values
    }
}

// MARK: - NoLabel

/// A special view type whose presence indicates that a `ColorWellView`'s
/// constructor should not modify the constructed view to include a label.
///
/// ** For internal use only **
@available(macOS 10.15, *)
internal struct NoLabel: View {
    /// Accessing this property results in a fatal error.
    var body: Never { return fatalError() }
}
#endif
