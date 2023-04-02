//
// ColorWellRepresentable.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - BridgedColorWell

/// A custom color well subclass that makes minor changes
/// to match SwiftUI's `ColorPicker`.
class BridgedColorWell: ColorWell {
    private var canPerformControlledColorObservation = true

    override var customIntrinsicContentSize: NSSize {
        switch style {
        case .expanded, .swatches:
            return super.customIntrinsicContentSize
        case .colorPanel:
            return super.customIntrinsicContentSize.insetBy(dx: -3, dy: 0.5)
        }
    }

    convenience init(color: NSColor, style: Style) {
        self.init(frame: Self.defaultFrame, color: color, style: style)
    }

    func setControlledColorObservation(_ body: @escaping (NSColor) -> Void) {
        enum LocalCache {
            static let storage = Storage<NSKeyValueObservation>()
        }

        LocalCache.storage.set(
            observe(\.color, options: .new) { colorWell, change in
                guard
                    colorWell.canPerformControlledColorObservation,
                    let newValue = change.newValue
                else {
                    return
                }
                body(newValue)
            },
            forObject: self
        )
    }

    func withoutPerformingControlledColorObservation(perform body: () throws -> Void) rethrows {
        let cachedState = canPerformControlledColorObservation
        canPerformControlledColorObservation = false
        defer {
            canPerformControlledColorObservation = cachedState
        }
        try body()
    }
}

// MARK: - ColorWellRepresentable

/// An `NSViewRepresentable` wrapper around a `ColorWell`.
@available(macOS 10.15, *)
struct ColorWellRepresentable: NSViewRepresentable {
    /// The configuration used to create the color well.
    let configuration: ColorWellConfiguration

    @Binding var color: NSColor?

    init(configuration: ColorWellConfiguration) {
        self.configuration = configuration
        self._color = configuration.makeColorBinding()
    }

    /// Creates and returns this view's underlying color well.
    func makeNSView(context: Context) -> BridgedColorWell {
        let colorWell: BridgedColorWell = {
            guard let color = configuration.color else {
                guard let style = context.environment.colorWellStyleConfiguration.style else {
                    return BridgedColorWell()
                }
                return BridgedColorWell(style: style)
            }
            guard let style = context.environment.colorWellStyleConfiguration.style else {
                return BridgedColorWell(color: color)
            }
            return BridgedColorWell(color: color, style: style)
        }()
        if color != nil {
            colorWell.setControlledColorObservation { newValue in
                color = newValue
            }
        }
        return colorWell
    }

    /// Updates the color well's configuration to the most recent
    /// values stored in the environment.
    func updateNSView(_ colorWell: BridgedColorWell, context: Context) {
        updateColor(colorWell)
        updateStyle(colorWell, context: context)
        updateChangeHandlers(colorWell, context: context)
        updateSwatchColors(colorWell, context: context)
        updateIsEnabled(colorWell, context: context)
        configuration.updateShowsAlpha(colorWell)
    }

    /// Updates the color well's color, without performing its
    /// controlled color observation.
    func updateColor(_ colorWell: BridgedColorWell) {
        guard let color else {
            return
        }
        colorWell.withoutPerformingControlledColorObservation {
            if colorWell.color != color {
                colorWell.color = color
            }
        }
    }

    /// Updates the color well's style to the most recent configuration
    /// stored in the environment.
    func updateStyle(_ colorWell: BridgedColorWell, context: Context) {
        if let style = context.environment.colorWellStyleConfiguration.style {
            colorWell.style = style
        }
    }

    /// Updates the color well's change handlers to the most recent
    /// value stored in the environment.
    func updateChangeHandlers(_ colorWell: BridgedColorWell, context: Context) {
        // If an action was added to the configuration, it can only have
        // happened on initialization, so it should come first.
        var changeHandlers = Array(compacting: [configuration.action])

        // @ViewBuilder blocks are evaluated from the outside in. This causes
        // the change handlers that were added nearest to the color well in
        // the view hierarchy to be added last in the environment. Reversing
        // the stored handlers returns the correct order.
        changeHandlers += context.environment.changeHandlers.reversed()

        // Overwrite the current change handlers. DO NOT APPEND, or more and
        // more duplicate actions will be added every time the view updates.
        colorWell.changeHandlers = changeHandlers
    }

    /// Updates the color well's swatch colors to the most recent
    /// value stored in the environment.
    func updateSwatchColors(_ colorWell: BridgedColorWell, context: Context) {
        if let swatchColors = context.environment.swatchColors {
            colorWell.swatchColors = swatchColors
        }
    }

    /// Updates the color well's `isEnabled` value to the most recent
    /// value stored in the environment.
    func updateIsEnabled(_ colorWell: BridgedColorWell, context: Context) {
        colorWell.isEnabled = context.environment.isEnabled
    }
}
#endif
