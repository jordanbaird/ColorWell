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
internal struct ColorWellViewLayout<Label: View, LabelCandidate: View, Content: View>: View {
    /// The layout view's optional label builder.
    let label: (() -> LabelCandidate)?

    /// The layout view's content builder.
    let content: () -> Content

    /// The layout view's content view.
    var body: some View {
        if let label {
            HStack(alignment: .center) {
                label()
                content()
            }
        } else {
            content()
        }
    }

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
        if
            LabelCandidate.self == Label.self,
            Label.self != NoLabel.self
        {
            self.label = makeIndirect(label)
        } else {
            self.label = nil
        }
        self.content = makeIndirect(content)
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
