//
// ColorWellPopoverContainerView.swift
// ColorWell
//

import Cocoa

/// A view that contains a grid of selectable color swatches.
class ColorWellPopoverContainerView: NSView {
    private weak var context: ColorWellPopoverContext?

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
        let padding: CGFloat
        switch context.colorWell?.style {
        case .swatches:
            padding = 15
        default:
            padding = 20
        }
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: layoutView.widthAnchor, constant: padding).isActive = true
        heightAnchor.constraint(equalTo: layoutView.heightAnchor, constant: padding).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Accessibility
extension ColorWellPopoverContainerView {
    override func accessibilityChildren() -> [Any]? {
        context.map { [$0.layoutView] }
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .group
    }
}
