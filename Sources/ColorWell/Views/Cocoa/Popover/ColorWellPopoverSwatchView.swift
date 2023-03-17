//
// ColorWellPopoverSwatchView.swift
// ColorWell
//

import Cocoa

/// A view that provides the layout for a popover's color swatches.
class ColorWellPopoverSwatchView: NSGridView {
    private weak var context: ColorWellPopoverContext?

    var selectedSwatch: ColorSwatch? {
        context?.swatches.first { $0.isSelected }
    }

    init(context: ColorWellPopoverContext) {
        self.context = context

        super.init(frame: .zero)

        rowSpacing = 1
        columnSpacing = 1

        for row in makeRows() {
            addRow(with: row)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Instance Methods
extension ColorWellPopoverSwatchView {
    private func makeRows() -> [[ColorSwatch]] {
        guard let context else {
            return []
        }
        var currentRow = [ColorSwatch]()
        var rows = [[ColorSwatch]]()
        for swatch in context.swatches {
            if currentRow.count >= context.maxItemsPerRow {
                rows.append(currentRow)
                currentRow.removeAll()
            }
            currentRow.append(swatch)
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
}

// MARK: Overrides
extension ColorWellPopoverSwatchView {
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let swatch = context?.swatches.first { swatch in
            swatch.frameConvertedToWindow.contains(event.locationInWindow)
        }
        swatch?.select()
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        selectedSwatch?.performAction()
    }
}

// MARK: Accessibility
extension ColorWellPopoverSwatchView {
    override func accessibilityParent() -> Any? {
        context?.layoutView
    }

    override func accessibilityChildren() -> [Any]? {
        context?.swatches
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .layoutArea
    }
}
