//
// ColorWellPopoverContext.swift
// ColorWell
//

import Cocoa

/// A central context for the elements of a color well's popover.
class ColorWellPopoverContext {
    private(set) weak var colorWell: ColorWell?

    private(set) lazy var popover = ColorWellPopover(context: self)
    private(set) lazy var popoverViewController = ColorWellPopoverViewController(context: self)

    private(set) lazy var containerView = ColorWellPopoverContainerView(context: self)
    private(set) lazy var layoutView = ColorWellPopoverLayoutView(context: self)
    private(set) lazy var swatchView = ColorWellPopoverSwatchView(context: self)

    private(set) lazy var swatchCount = colorWell?.swatchColors.count ?? 0
    private(set) lazy var maxItemsPerRow = max(4, Int(Double(swatchCount).squareRoot().rounded(.up)))
    private(set) lazy var rowCount = Int((Double(swatchCount) / Double(maxItemsPerRow)).rounded(.up))

    private(set) lazy var swatches: [ColorSwatch] = {
        guard let colorWell else {
            return []
        }
        return colorWell.swatchColors.map { color in
            ColorSwatch(color: color, context: self)
        }
    }()

    /// Creates a context for the specified color well.
    init(colorWell: ColorWell) {
        self.colorWell = colorWell
    }

    /// Removes the strong reference to this instance from the color well.
    func removeStrongReference() {
        guard colorWell?.popoverContext === self else {
            return
        }
        colorWell?.popoverContext = nil
    }

    deinit {
        removeStrongReference()
    }
}
