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
internal struct ColorWellViewLayout: View {
    /// The values used to construct the layout view.
    let context: ColorWellViewContext

    /// The layout view's content view.
    var content: some View {
        ColorWellRepresentable(color: context.color, showsAlpha: context.showsAlpha)
            .onColorChange(maybePerform: context.action)
            .fixedSize()
    }

    /// The body of the layout view.
    var body: some View {
        if let label = context.label {
            HStack(alignment: .center) {
                label
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
    init(context: ColorWellViewContext) {
        self.context = context
    }
}
#endif
