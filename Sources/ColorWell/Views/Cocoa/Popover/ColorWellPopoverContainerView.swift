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
        NSLayoutConstraint.activate([
            layoutView.centerXAnchor.constraint(equalTo: centerXAnchor),
            layoutView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        // Padding should vary based on the style.
        let padding: CGFloat
        switch context.colorWell?.style {
        case .swatches:
            padding = 15
        default:
            padding = 20
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: layoutView.widthAnchor, constant: padding),
            heightAnchor.constraint(equalTo: layoutView.heightAnchor, constant: padding),
        ])
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
