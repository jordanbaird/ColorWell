//
// ViewModifiers.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
extension View {
    /// Sets the style for color wells within this view.
    public func colorWellStyle<S: ColorWellStyle>(_ style: S) -> some View {
        transformEnvironment(\.colorWellStyleConfiguration) { configuration in
            configuration = style._configuration
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
            swatchColors = colors.map(NSColor.init)
        }
    }
}
#endif
