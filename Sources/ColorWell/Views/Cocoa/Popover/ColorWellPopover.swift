//
// ColorWellPopover.swift
// ColorWell
//

import Cocoa

/// A popover that contains a grid of selectable color swatches.
class ColorWellPopover: NSPopover {
    /// The central context for the popover and its elements.
    weak var context: ColorWellPopoverContext?

    /// Creates a popover using the specified central context.
    init(context: ColorWellPopoverContext) {
        self.context = context
        super.init()
        contentViewController = context.popoverViewController
        behavior = .transient
        delegate = context.popoverViewController
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )

        guard let context else {
            return
        }

        context.containerView.window?.makeFirstResponder(nil)

        guard
            let color = context.colorWell?.color,
            let swatch = context.swatches.first(where: { $0.color.resembles(color) })
        else {
            return
        }

        swatch.select()
    }
}
