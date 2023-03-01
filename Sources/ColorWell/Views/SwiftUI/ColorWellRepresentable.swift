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

    /// The model used to construct the color well.
    private let model: ColorWellViewModel

    /// A Boolean value that indicates whether the this view should
    /// update its underlying color well's `showsAlpha` property whenever
    /// the view itself updates.
    var shouldUpdateShowsAlpha: Bool {
        model.showsAlpha != nil
    }

    /// A binding to a Boolean value indicating whether the color panel
    /// that belongs to this view's underlying color well shows alpha
    /// values and an opacity slider.
    @Binding var showsAlpha: Bool

    // MARK: Initializers

    /// Creates a color well representable view using the given model.
    init(model: ColorWellViewModel) {
        self.model = model
        if let showsAlpha = model.showsAlpha {
            self._showsAlpha = showsAlpha
        } else {
            self._showsAlpha = .constant(true)
        }
    }

    // MARK: Instance Methods

    /// Creates and returns this view's underlying color well.
    func makeNSView(context: Context) -> ColorWell {
        let colorWell: ColorWell
        if let color = model.take(\.color) {
            colorWell = ColorWell(color: color)
        } else {
            colorWell = ColorWell()
        }
        updateNSView(colorWell, context: context)
        return colorWell
    }

    /// Updates the color well's configuration to the most recent
    /// values stored in the environment.
    func updateNSView(_ colorWell: ColorWell, context: Context) {
        updateStyle(colorWell, context: context)
        updateChangeHandlers(colorWell, context: context)
        updateSwatchColors(colorWell, context: context)

        colorWell.isEnabled = context.environment.isEnabled

        if shouldUpdateShowsAlpha {
            colorWell.showsAlpha = showsAlpha
        }
    }

    /// Updates the color well's style to the most recent configuration
    /// stored in the environment.
    func updateStyle(_ colorWell: ColorWell, context: Context) {
        if let style = context.environment.colorWellStyleConfiguration.style {
            colorWell.style = style
        }
    }

    /// Updates the color well's change handlers to the most recent
    /// values stored in the environment.
    func updateChangeHandlers(_ colorWell: ColorWell, context: Context) {
        // If an action was added to the model, it can only have happened on
        // initialization, so it should come first.
        var changeHandlers = Array(compacting: [model.action])

        // @ViewBuilder variables are evaluated from outside in. This causes
        // the handlers that were added first in the view hierarchy to be the
        // last ones added to the environment. Reversing the stored handlers
        // results in the correct order.
        changeHandlers += context.environment.changeHandlers.reversed()

        // Overwrite the current change handlers. DO NOT APPEND, or more and
        // more duplicate actions will be added every time the view updates.
        colorWell.changeHandlers = changeHandlers
    }

    /// Updates the color well's swatch colors to the most recent
    /// values stored in the environment.
    func updateSwatchColors(_ colorWell: ColorWell, context: Context) {
        if
            #available(macOS 11.0, *),
            let swatchColors = context.environment.swatchColors
        {
            colorWell.swatchColors = swatchColors
        }
    }
}
#endif
