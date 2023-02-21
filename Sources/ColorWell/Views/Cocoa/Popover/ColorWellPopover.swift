//===----------------------------------------------------------------------===//
//
// ColorWellPopover.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

// MARK: - ColorWellPopover

/// A popover that contains a grid of selectable color swatches.
internal class ColorWellPopover: NSPopover {
    weak var context: ColorWellPopoverContext?

    var window: NSWindow? {
        context?.containerView.window
    }

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

        window?.makeFirstResponder(nil)

        guard
            let color = context?.colorWell?.color,
            let swatch = context?.swatches.first(where: { $0.color.resembles(color) })
        else {
            return
        }

        swatch.select()
    }
}
