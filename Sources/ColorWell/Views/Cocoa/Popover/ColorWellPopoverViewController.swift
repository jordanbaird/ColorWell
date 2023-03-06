//
// ColorWellPopoverViewController.swift
// ColorWell
//

import Cocoa

/// A view controller that controls a view that contains a grid
/// of selectable color swatches.
class ColorWellPopoverViewController: NSViewController {
    private weak var context: ColorWellPopoverContext?

    init(context: ColorWellPopoverContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
        self.view = context.containerView
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorWellPopoverViewController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        // Async so that ColorWellSegment's mouseDown method
        // has a chance to run before the context becomes nil.
        DispatchQueue.main.async { [weak context] in
            context?.removeStrongReference()
        }
    }
}
