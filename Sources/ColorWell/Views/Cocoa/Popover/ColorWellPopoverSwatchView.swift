//
// ColorWellPopoverSwatchView.swift
// ColorWell
//

import Cocoa

// MARK: - ColorWellPopoverSwatchView

/// A view that provides the layout for a popover's color swatches.
class ColorWellPopoverSwatchView: NSGridView {
    private weak var context: ColorWellPopoverContext?

    /// The swatch that is currently selected, if any.
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

// MARK: ColorWellPopoverSwatchView Instance Methods
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

// MARK: ColorWellPopoverSwatchView Overrides
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

// MARK: ColorWellPopoverSwatchView Accessibility
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

// MARK: - ColorSwatch

/// A rectangular, clickable color swatch that is displayed inside
/// of a color well's popover.
///
/// When a swatch is clicked, the color well's color value is set
/// to the color value of the swatch.
class ColorSwatch: NSView {
    private weak var context: ColorWellPopoverContext?

    /// The swatch's color value.
    let color: NSColor

    /// A layer that draws a bezel around the swatch.
    private var bezelLayer: CAShapeLayer?

    /// The standard width of a swatch's border.
    private let borderWidth: CGFloat = 2

    /// The standard corner radius for a swatch.
    private let cornerRadius: CGFloat = 1

    /// A Boolean value that indicates whether the swatch is selected.
    ///
    /// In most cases, this value is true if the swatch's color matches
    /// the color value of its respective color well. However, setting
    /// this value does not automatically update the color well, although
    /// it does automatically highlight the swatch and unhighlight its
    /// siblings.
    private(set) var isSelected = false {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            defer {
                updateBezel()
            }
            guard isSelected else {
                return
            }
            iterateOtherSwatches(where: [\.isSelected]) { swatch in
                swatch.isSelected = false
            }
        }
    }

    /// The color of the swatch, converted to a standardized format
    /// for display.
    private var displayColor: NSColor {
        color.usingColorSpace(.sRGB) ?? color
    }

    /// The computed border color of the swatch, created based on its color.
    private var borderColor: CGColor {
        CGColor(gray: (1 - color.averageBrightness) / 4, alpha: 0.15)
    }

    /// The computed bezel color of the swatch.
    ///
    /// - Note: Currently, this color is always white.
    private var bezelColor: CGColor { .white }

    /// Creates a swatch with the given color and context.
    init(
        color: NSColor,
        context: ColorWellPopoverContext
    ) {
        self.color = color
        self.context = context

        let size = Self.size(forRowCount: context.rowCount)

        super.init(frame: NSRect(origin: .zero, size: size))

        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ColorSwatch Static Methods
extension ColorSwatch {
    /// Returns the correct size for a swatch based on the row count that
    /// is passed into it. Higher row counts result in smaller swatches.
    static func size(forRowCount rowCount: Int) -> NSSize {
        if rowCount < 6 {
            return NSSize(width: 37, height: 20)
        } else if rowCount < 10 {
            return NSSize(width: 31, height: 18)
        }
        return NSSize(width: 15, height: 15)
    }
}

// MARK: ColorSwatch Instance Methods
extension ColorSwatch {
    /// Returns all swatches in the swatch view that match the given conditions.
    private func swatches(matching conditions: [(ColorSwatch) -> Bool]) -> [ColorSwatch] {
        guard let context else {
            return []
        }
        return context.swatches.filter { swatch in
            conditions.allSatisfy { condition in
                condition(swatch)
            }
        }
    }

    /// Iterates through all other swatches in the swatch view and executes
    /// the given block of code, provided a set of conditions are met.
    private func iterateOtherSwatches(where conditions: [(ColorSwatch) -> Bool], block: (ColorSwatch) -> Void) {
        let conditions = conditions + [{ $0 !== self }]
        for swatch in swatches(matching: conditions) {
            block(swatch)
        }
    }

    /// Updates the swatch's border according to the current value of
    /// the swatch's `isSelected` property.
    private func updateBorder() {
        layer?.borderWidth = borderWidth
        if isSelected {
            layer?.borderColor = bezelColor
        } else {
            layer?.borderColor = borderColor
        }
    }

    /// Draws a rounded bezel around the swatch, if the swatch is
    /// selected. If the swatch is not selected, its border is updated
    /// and the method returns early.
    private func updateBezel() {
        bezelLayer?.removeFromSuperlayer()
        bezelLayer = nil

        guard
            let layer,
            isSelected
        else {
            updateBorder()
            return
        }
        let bezelLayer = CAShapeLayer()

        bezelLayer.masksToBounds = false
        bezelLayer.frame = layer.bounds

        bezelLayer.path = CGPath(
            roundedRect: layer.bounds,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )

        bezelLayer.fillColor = .clear
        bezelLayer.strokeColor = bezelColor
        bezelLayer.lineWidth = borderWidth

        bezelLayer.shadowColor = NSColor.shadowColor.cgColor
        bezelLayer.shadowRadius = 0.5
        bezelLayer.shadowOpacity = 0.25
        bezelLayer.shadowOffset = .zero

        bezelLayer.shadowPath = CGPath(
            roundedRect: layer.bounds.insetBy(dx: borderWidth, dy: borderWidth),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        ).copy(
            strokingWithWidth: borderWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 0
        )

        layer.addSublayer(bezelLayer)
        layer.masksToBounds = false
        layer.borderColor = bezelColor
        layer.borderWidth = borderWidth

        self.bezelLayer = bezelLayer
    }

    /// Selects the swatch, drawing a bezel around its edges and ensuring
    /// that all other swatches in the swatch view are deselected.
    func select() {
        // Setting the `isSelected` property automatically highlights the
        // swatch and unhighlights all other swatches in the layout view.
        isSelected = true
    }

    /// Performs the swatch's action, setting the color well's color to
    /// that of the swatch, and closing the popover.
    func performAction() {
        guard let context else {
            return
        }
        context.colorWell?.color = color
        context.popover.close()
    }
}

// MARK: ColorSwatch Overrides
extension ColorSwatch {
    override func draw(_ dirtyRect: NSRect) {
        displayColor.drawSwatch(in: dirtyRect)
        updateBorder()
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        select()
    }
}

// MARK: ColorSwatch Accessibility
extension ColorSwatch {
    override func accessibilityLabel() -> String? {
        "color swatch"
    }

    override func accessibilityParent() -> Any? {
        context?.swatchView
    }

    override func accessibilityPerformPress() -> Bool {
        performAction()
        return true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func isAccessibilitySelected() -> Bool {
        isSelected
    }
}
