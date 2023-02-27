//
// ColorWellLayoutView.swift
// ColorWell
//

import Cocoa

/// A grid view that displays color well segments side by side.
internal class ColorWellLayoutView: NSGridView {

    // MARK: Instance Properties

    /// A segment that displays a color swatch with the color well's
    /// current color selection.
    let swatchSegment: SwatchSegment

    /// A segment that, when pressed, toggles the color panel.
    let toggleSegment: ToggleSegment

    /// The row that contains the layout view's segments.
    private var row: NSGridRow?

    /// A layer that enables the color well to mimic the appearance of a
    /// native macOS UI element by drawing a small bezel around the edge
    /// of the layout view.
    private var bezelLayer: CAGradientLayer?

    /// The key-value observations retained by the layout view.
    private var observations = Set<NSKeyValueObservation>()

    // MARK: Initializers

    /// Creates a layout view with the given color well.
    init(colorWell: ColorWell) {
        swatchSegment = SwatchSegment(colorWell: colorWell)
        toggleSegment = ToggleSegment(colorWell: colorWell)

        super.init(frame: .zero)

        wantsLayer = true
        columnSpacing = 0
        xPlacement = .fill
        yPlacement = .fill

        observations.observe(
            colorWell,
            keyPath: \.style,
            options: .initial
        ) { [weak self] colorWell, _ in
            self?.setRow(for: colorWell.style)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Instance Methods
extension ColorWellLayoutView {
    /// Removes the given row from the layout view.
    func removeRow(_ row: NSGridRow) {
        for n in 0..<row.numberOfCells {
            row.cell(at: n).contentView?.removeFromSuperview()
        }
        removeRow(at: index(of: row))
    }

    /// Sets the layout view's row according to the given color well style.
    func setRow(for style: ColorWell.Style) {
        if let row {
            removeRow(row)
        }

        switch style {
        case .expanded:
            row = addRow(with: [swatchSegment, toggleSegment])
        case .colorPanel:
            row = addRow(with: [swatchSegment])
        case .swatches:
            row = addRow(with: [swatchSegment])
        }
    }


    /// Updates the bezel layer for the given rectangle.
    func updateBezelLayer(_ dirtyRect: NSRect) {
        bezelLayer?.removeFromSuperlayer()
        bezelLayer = nil

        guard let layer else {
            return
        }

        let bezelLayer = CAGradientLayer()
        bezelLayer.colors = [
            CGColor.clear,
            CGColor.clear,
            CGColor.clear,
            CGColor(gray: 1, alpha: 0.125),
        ]
        bezelLayer.needsDisplayOnBoundsChange = true
        bezelLayer.frame = layer.bounds

        let insetAmount = ColorWell.lineWidth / 2
        let bezelFrame = bezelLayer.frame.insetBy(dx: insetAmount, dy: insetAmount)

        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = .clear
        maskLayer.strokeColor = .black
        maskLayer.lineWidth = ColorWell.lineWidth
        maskLayer.needsDisplayOnBoundsChange = true
        maskLayer.frame = bezelLayer.frame
        maskLayer.path = .colorWellPath(rect: bezelFrame)

        bezelLayer.mask = maskLayer

        layer.addSublayer(bezelLayer)
        bezelLayer.zPosition += 1

        self.bezelLayer = bezelLayer
    }
}

// MARK: Overrides
extension ColorWellLayoutView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateBezelLayer(dirtyRect)
    }
}
