//
// ColorWellLayoutView.swift
// ColorWell
//

import Cocoa

/// A grid view that displays color well segments side by side.
class ColorWellLayoutView: NSGridView {

    // MARK: Properties

    /// A constructor for the layout view's swatch segment.
    private let makeSwatchSegment: () -> SwatchSegment?

    /// A constructor for the layout view's toggle segment.
    private let makeToggleSegment: () -> ToggleSegment?

    /// Backing storage for the layout view's swatch segment.
    private var cachedSwatchSegment: SwatchSegment?

    /// Backing storage for the layout view's toggle segment.
    private var cachedToggleSegment: ToggleSegment?

    /// A segment that displays a color swatch with the color well's
    /// current color selection.
    var swatchSegment: SwatchSegment? {
        if let cachedSwatchSegment {
            return cachedSwatchSegment
        }
        cachedSwatchSegment = makeSwatchSegment()
        return cachedSwatchSegment
    }

    /// A segment that, when pressed, toggles the color panel.
    var toggleSegment: ToggleSegment? {
        if let cachedToggleSegment {
            return cachedToggleSegment
        }
        cachedToggleSegment = makeToggleSegment()
        return cachedToggleSegment
    }

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
        makeSwatchSegment = { [weak colorWell] in
            SwatchSegment(colorWell: colorWell)
        }
        makeToggleSegment = { [weak colorWell] in
            ToggleSegment(colorWell: colorWell)
        }

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
            guard
                let swatchSegment,
                let toggleSegment
            else {
                return
            }
            row = addRow(with: [swatchSegment, toggleSegment])
        case .swatches, .colorPanel:
            cachedToggleSegment = nil
            guard let swatchSegment else {
                return
            }
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
