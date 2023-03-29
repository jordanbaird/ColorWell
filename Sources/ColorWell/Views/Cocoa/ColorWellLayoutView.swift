//
// ColorWellLayoutView.swift
// ColorWell
//

import Cocoa

/// A grid view that displays color well segments side by side.
class ColorWellLayoutView: NSGridView {

    // MARK: Properties

    /// Backing storage for the layout view's segments.
    private let cachedSegments = (
        borderedSwatchSegment: OptionalCache<ColorWellBorderedSwatchSegment>(),
        singlePullDownSwatchSegment: OptionalCache<ColorWellSinglePullDownSwatchSegment>(),
        partialPullDownSwatchSegment: OptionalCache<ColorWellPartialPullDownSwatchSegment>(),
        toggleSegment: OptionalCache<ColorWellToggleSegment>()
    )

    /// The row that contains the layout view's segments.
    private var row: NSGridRow?

    /// A layer that enables the color well to mimic the appearance of a
    /// native macOS UI element by drawing a small bezel around the edge
    /// of the layout view.
    private let cachedBezelLayer = Cache(CALayer(), id: NSRect())

    /// The key-value observations retained by the layout view.
    private var observations = Set<NSKeyValueObservation>()

    /// A segment that displays a color swatch with the color well's
    /// current color selection, and that toggles the color panel
    /// when pressed.
    var borderedSwatchSegment: ColorWellBorderedSwatchSegment? {
        cachedSegments.borderedSwatchSegment.recache()
        return cachedSegments.borderedSwatchSegment.cachedValue
    }

    /// A single-style segment that displays a color swatch with the
    /// color well's current color selection, and that triggers a pull
    /// down action when pressed.
    var singlePullDownSwatchSegment: ColorWellSinglePullDownSwatchSegment? {
        cachedSegments.singlePullDownSwatchSegment.recache()
        return cachedSegments.singlePullDownSwatchSegment.cachedValue
    }

    /// A partial-style segment that displays a color swatch with the
    /// color well's current color selection, and that triggers a pull
    /// down action when pressed.
    var partialPullDownSwatchSegment: ColorWellPartialPullDownSwatchSegment? {
        cachedSegments.partialPullDownSwatchSegment.recache()
        return cachedSegments.partialPullDownSwatchSegment.cachedValue
    }

    /// A segment that toggles the color panel when pressed.
    var toggleSegment: ColorWellToggleSegment? {
        cachedSegments.toggleSegment.recache()
        return cachedSegments.toggleSegment.cachedValue
    }

    // MARK: Initializers

    init(colorWell: ColorWell) {
        cachedSegments.borderedSwatchSegment.updateConstructor { [weak colorWell] in
            ColorWellBorderedSwatchSegment(colorWell: colorWell)
        }
        cachedSegments.singlePullDownSwatchSegment.updateConstructor { [weak colorWell] in
            ColorWellSinglePullDownSwatchSegment(colorWell: colorWell)
        }
        cachedSegments.partialPullDownSwatchSegment.updateConstructor { [weak colorWell] in
            ColorWellPartialPullDownSwatchSegment(colorWell: colorWell)
        }
        cachedSegments.toggleSegment.updateConstructor { [weak colorWell] in
            ColorWellToggleSegment(colorWell: colorWell)
        }
        cachedBezelLayer.updateConstructor { bounds in
            let bezelLayer = CAGradientLayer()
            bezelLayer.colors = [
                CGColor.clear,
                CGColor.clear,
                CGColor.clear,
                CGColor(gray: 1, alpha: 0.125),
            ]
            bezelLayer.needsDisplayOnBoundsChange = true
            bezelLayer.frame = bounds

            let lineWidth = ColorWell.lineWidth
            let insetBounds = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
            let bezelPath = CGPath.colorWellPath(rect: insetBounds)

            let maskLayer = CAShapeLayer()
            maskLayer.fillColor = .clear
            maskLayer.strokeColor = .black
            maskLayer.lineWidth = lineWidth
            maskLayer.needsDisplayOnBoundsChange = true
            maskLayer.frame = bounds
            maskLayer.path = bezelPath

            bezelLayer.mask = maskLayer
            bezelLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)

            return bezelLayer
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
            cachedSegments.borderedSwatchSegment.clear()
            cachedSegments.singlePullDownSwatchSegment.clear()
            guard
                let partialPullDownSwatchSegment,
                let toggleSegment
            else {
                return
            }
            row = addRow(with: [partialPullDownSwatchSegment, toggleSegment])
        case .swatches:
            cachedSegments.borderedSwatchSegment.clear()
            cachedSegments.partialPullDownSwatchSegment.clear()
            cachedSegments.toggleSegment.clear()
            guard let singlePullDownSwatchSegment else {
                return
            }
            row = addRow(with: [singlePullDownSwatchSegment])
        case .colorPanel:
            cachedSegments.singlePullDownSwatchSegment.clear()
            cachedSegments.partialPullDownSwatchSegment.clear()
            cachedSegments.toggleSegment.clear()
            guard let borderedSwatchSegment else {
                return
            }
            row = addRow(with: [borderedSwatchSegment])
        }
    }

    /// Updates the bezel layer for the given rectangle.
    func updateBezelLayer(_ dirtyRect: NSRect) {
        cachedBezelLayer.cachedValue.removeFromSuperlayer()

        guard let layer else {
            return
        }

        cachedBezelLayer.recache(id: dirtyRect)
        layer.addSublayer(cachedBezelLayer.cachedValue)
    }
}

// MARK: Overrides
extension ColorWellLayoutView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateBezelLayer(dirtyRect)
    }
}
