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
    /// The model used to construct the color well.
    let model: ColorWellViewModel

    /// The layout view's content view.
    var content: some View {
        ColorWellRepresentable(model: model).fixedSize()
    }

    /// The body of the layout view.
    var body: some View {
        if let label = model.label {
            HStack(alignment: .center) {
                label
                content
            }
        } else {
            content
        }
    }

    /// Creates a layout view from the given model.
    init(model: ColorWellViewModel) {
        self.model = model
    }
}
#endif
