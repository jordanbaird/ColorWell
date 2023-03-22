//
// ColorWellLayoutView.swift
// ColorWell
//

import Cocoa

/// A grid view that displays color well segments side by side.
class ColorWellLayoutView: NSGridView {

    // MARK: Properties

    /// A constructor for the layout view's bordered swatch segment.
    private var makeBorderedSwatchSegment: () -> ColorWellBorderedSwatchSegment? = { nil }

    /// A constructor for the layout view's pull down swatch segment.
    private var makePullDownSwatchSegment: () -> ColorWellPullDownSwatchSegment? = { nil }

    /// A constructor for the layout view's toggle segment.
    private var makeToggleSegment: () -> ColorWellToggleSegment? = { nil }

    /// Backing storage for the layout view's bordered swatch segment.
    private var cachedBorderedSwatchSegment: ColorWellBorderedSwatchSegment?

    /// Backing storage for the layout view's pull down swatch segment.
    private var cachedPullDownSwatchSegment: ColorWellPullDownSwatchSegment?

    /// Backing storage for the layout view's toggle segment.
    private var cachedToggleSegment: ColorWellToggleSegment?

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
        if let cachedBorderedSwatchSegment {
            return cachedBorderedSwatchSegment
        }
        cachedBorderedSwatchSegment = makeBorderedSwatchSegment()
        return cachedBorderedSwatchSegment
    }

    /// A segment that displays a color swatch with the color well's
    /// current color selection, and that triggers a pull down action
    /// when pressed.
    var pullDownSwatchSegment: ColorWellPullDownSwatchSegment? {
        if let cachedPullDownSwatchSegment {
            return cachedPullDownSwatchSegment
        }
        cachedPullDownSwatchSegment = makePullDownSwatchSegment()
        return cachedPullDownSwatchSegment
    }

    /// A segment that toggles the color panel when pressed.
    var toggleSegment: ColorWellToggleSegment? {
        if let cachedToggleSegment {
            return cachedToggleSegment
        }
        cachedToggleSegment = makeToggleSegment()
        return cachedToggleSegment
    }

    /// The current segments in the layout view.
    var currentSegments: [ColorWellSegment] {
        let rangeOfRows = 0..<numberOfRows
        let rangeOfColumns = 0..<numberOfColumns
        return rangeOfRows.flatMap { rowIndex in
            rangeOfColumns.compactMap { columnIndex in
                let cell = cell(atColumnIndex: columnIndex, rowIndex: rowIndex)
                return cell.contentView as? ColorWellSegment
            }
        }
    }

    // MARK: Initializers

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        columnSpacing = 0
        xPlacement = .fill
        yPlacement = .fill
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Instance Methods
extension ColorWellLayoutView {
    /// Sets the layout view's segment constructors using
    /// the specified color well.
    func setSegmentConstructors(using colorWell: ColorWell) {
        makeBorderedSwatchSegment = { [weak colorWell] in
            ColorWellBorderedSwatchSegment(colorWell: colorWell)
        }
        makePullDownSwatchSegment = { [weak colorWell] in
            ColorWellPullDownSwatchSegment(colorWell: colorWell)
        }
        makeToggleSegment = { [weak colorWell] in
            ColorWellToggleSegment(colorWell: colorWell)
        }

        observations.insertObservation(
            for: colorWell,
            keyPath: \.style,
            options: .initial
        ) { [weak self] colorWell, _ in
            self?.setRow(for: colorWell.style)
        }
    }

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
                let pullDownSwatchSegment,
                let toggleSegment
            else {
                return
            }
            row = addRow(with: [pullDownSwatchSegment, toggleSegment])
        case .swatches:
            cachedToggleSegment = nil
            guard let pullDownSwatchSegment else {
                return
            }
            row = addRow(with: [pullDownSwatchSegment])
        case .colorPanel:
            cachedToggleSegment = nil
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
