//
// ColorWellRepresentable.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI

/// An `NSViewRepresentable` wrapper around a `ColorWell`.
///
/// ** For internal use only **
@available(macOS 10.15, *)
internal struct ColorWellRepresentable: NSViewRepresentable {

    // MARK: Instance Properties

    /// The color used to create this view's underlying color well.
    let color: NSColor?

    /// A Boolean value that indicates whether the this view should
    /// update its underlying color well's `showsAlpha` property whenever
    /// the view itself updates.
    let shouldUpdateShowsAlpha: Bool

    /// A binding to a Boolean value indicating whether the color panel
    /// that belongs to this view's underlying color well shows alpha
    /// values and an opacity slider.
    @Binding var showsAlpha: Bool

    // MARK: Initializers

    /// Creates a representable view with the given color, and an
    /// optional binding that determines the value of the underlying
    /// color well's `showsAlpha` property.
    init(color: NSColor?, showsAlpha: Binding<Bool>?) {
        self.color = color
        if let showsAlpha {
            self.shouldUpdateShowsAlpha = true
            self._showsAlpha = showsAlpha
        } else {
            self.shouldUpdateShowsAlpha = false
            self._showsAlpha = .constant(true)
        }
    }

    // MARK: Instance Methods

    /// Creates and returns this view's underlying color well.
    func makeNSView(context: Context) -> ColorWell {
        let nsView: ColorWell
        if let color {
            nsView = ColorWell(color: color)
        } else {
            nsView = ColorWell()
        }
        updateNSView(nsView, context: context)
        return nsView
    }

    /// Updates this view's underlying color well using the specified context.
    func updateNSView(_ nsView: ColorWell, context: Context) {
        nsView.changeHandlers = changeHandlers(for: context)
        nsView.isEnabled = context.environment.isEnabled

        if shouldUpdateShowsAlpha {
            nsView.showsAlpha = showsAlpha
        }

        if
            #available(macOS 11.0, *),
            let swatchColors = context.environment.swatchColors
        {
            nsView.swatchColors = swatchColors
        }

        if let style = context.environment.colorWellStyleConfiguration.style {
            nsView.style = style
        }
    }

    /// Returns the change handlers stored in the view's environment for the
    /// specified context.
    func changeHandlers(for context: Context) -> [(NSColor) -> Void] {
        // @ViewBuilder variables are evaluated from outside in. This causes
        // the handlers that were added first in the view hierarchy to be the
        // last ones added to the environment. Reversing the stored handlers
        // results in the correct order.
        context.environment.changeHandlers.reversed()
    }
}
#endif
