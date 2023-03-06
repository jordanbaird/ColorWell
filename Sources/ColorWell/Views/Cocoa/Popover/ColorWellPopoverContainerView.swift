//
// ColorWellPopoverContainerView.swift
// ColorWell
//

import Cocoa

/// A view that contains a grid of selectable color swatches.
class ColorWellPopoverContainerView: NSView {
    /// The central context for the popover and its elements.
    weak var context: ColorWellPopoverContext?

    /// Creates a container view using the specified central context.
    init(context: ColorWellPopoverContext) {
        self.context = context

        super.init(frame: .zero)

        let layoutView = context.layoutView
        addSubview(layoutView)

        // Center the layout view inside the container.
        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // Padding should vary based on the style.
        let constant: CGFloat
        switch context.colorWell?.style {
        case .swatches:
            constant = 15
        default:
            constant = 20
        }
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: layoutView.widthAnchor, constant: constant).isActive = true
        heightAnchor.constraint(equalTo: layoutView.heightAnchor, constant: constant).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Accessibility

    override func accessibilityChildren() -> [Any]? {
        context.map { [$0.layoutView] }
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .group
    }
}
