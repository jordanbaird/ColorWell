//
// ColorWellLayoutView.swift
// ColorWell
//

import Cocoa

/// A grid view that displays color well segments side by side.
class ColorWellLayoutView: NSGridView {

    // MARK: Properties

    /// Constructors for the layout view's segments.
    private var constructors: (
        borderedSwatchSegment: () -> ColorWellBorderedSwatchSegment?,
        singlePullDownSwatchSegment: () -> ColorWellSinglePullDownSwatchSegment?,
        partialPullDownSwatchSegment: () -> ColorWellPartialPullDownSwatchSegment?,
        toggleSegment: () -> ColorWellToggleSegment?
    )

    /// Backing storage for the layout view's segments.
    private var cachedSegments: (
        borderedSwatchSegment: ColorWellBorderedSwatchSegment?,
        singlePullDownSwatchSegment: ColorWellSinglePullDownSwatchSegment?,
        partialPullDownSwatchSegment: ColorWellPartialPullDownSwatchSegment?,
        toggleSegment: ColorWellToggleSegment?
    )

    /// The row that contains the layout view's segments.
    private var row: NSGridRow?

    /// A layer that enables the color well to mimic the appearance of a
    /// native macOS UI element by drawing a small bezel around the edge
    /// of the layout view.
    private var cachedBezelLayer: CAGradientLayer?

    /// The key-value observations retained by the layout view.
    private var observations = Set<NSKeyValueObservation>()

    /// A segment that displays a color swatch with the color well's
    /// current color selection, and that toggles the color panel
    /// when pressed.
    var borderedSwatchSegment: ColorWellBorderedSwatchSegment? {
        if let segment = cachedSegments.borderedSwatchSegment {
            return segment
        }
        cachedSegments.borderedSwatchSegment = constructors.borderedSwatchSegment()
        return cachedSegments.borderedSwatchSegment
    }

    /// A single-style segment that displays a color swatch with the
    /// color well's current color selection, and that triggers a pull
    /// down action when pressed.
    var singlePullDownSwatchSegment: ColorWellSinglePullDownSwatchSegment? {
        if let segment = cachedSegments.singlePullDownSwatchSegment {
            return segment
        }
        cachedSegments.singlePullDownSwatchSegment = constructors.singlePullDownSwatchSegment()
        return cachedSegments.singlePullDownSwatchSegment
    }

    /// A partial-style segment that displays a color swatch with the
    /// color well's current color selection, and that triggers a pull
    /// down action when pressed.
    var partialPullDownSwatchSegment: ColorWellPartialPullDownSwatchSegment? {
        if let segment = cachedSegments.partialPullDownSwatchSegment {
            return segment
        }
        cachedSegments.partialPullDownSwatchSegment = constructors.partialPullDownSwatchSegment()
        return cachedSegments.partialPullDownSwatchSegment
    }

    /// A segment that toggles the color panel when pressed.
    var toggleSegment: ColorWellToggleSegment? {
        if let segment = cachedSegments.toggleSegment {
            return segment
        }
        cachedSegments.toggleSegment = constructors.toggleSegment()
        return cachedSegments.toggleSegment
    }

    // MARK: Initializers

    init(colorWell: ColorWell) {
        constructors.borderedSwatchSegment = { [weak colorWell] in
            ColorWellBorderedSwatchSegment(colorWell: colorWell)
        }
        constructors.singlePullDownSwatchSegment = { [weak colorWell] in
            ColorWellSinglePullDownSwatchSegment(colorWell: colorWell)
        }
        constructors.partialPullDownSwatchSegment = { [weak colorWell] in
            ColorWellPartialPullDownSwatchSegment(colorWell: colorWell)
        }
        constructors.toggleSegment = { [weak colorWell] in
            ColorWellToggleSegment(colorWell: colorWell)
        }

        super.init(frame: .zero)
        wantsLayer = true
        columnSpacing = 0
        xPlacement = .fill
        yPlacement = .fill

        observations.insertObservation(
            for: colorWell,
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
                let partialPullDownSwatchSegment,
                let toggleSegment
            else {
                return
            }
            row = addRow(with: [partialPullDownSwatchSegment, toggleSegment])
        case .swatches:
            cachedSegments.toggleSegment = nil
            guard let singlePullDownSwatchSegment else {
                return
            }
            row = addRow(with: [singlePullDownSwatchSegment])
        case .colorPanel:
            cachedSegments.toggleSegment = nil
            guard let borderedSwatchSegment else {
                return
            }
            row = addRow(with: [borderedSwatchSegment])
        }
    }

    /// Updates the bezel layer for the given rectangle.
    func updateBezelLayer() {
        cachedBezelLayer?.removeFromSuperlayer()
        cachedBezelLayer = nil

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

        cachedBezelLayer = bezelLayer
    }
}

// MARK: Overrides
extension ColorWellLayoutView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateBezelLayer()
    }
}
