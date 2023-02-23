//
// ColorWellPopoverViewController.swift
// ColorWell
//

import Cocoa

/// A view controller that controls a view that contains a grid
/// of selectable color swatches.
internal class ColorWellPopoverViewController: NSViewController {
    weak var context: ColorWellPopoverContext?

    /// Creates a popover view controller that controls
    /// the `containerView` found in the given context.
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

// MARK: NSPopoverDelegate
extension ColorWellPopoverViewController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        // Async so that ColorWellSegment's mouseDown method
        // has a chance to run before the context becomes nil.
        DispatchQueue.main.async { [weak context] in
            context?.removeStrongReference()
        }
    }
}
