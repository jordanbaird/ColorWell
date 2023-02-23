//
// ColorWellLayoutView.swift
// ColorWell
//

import Cocoa

/// A grid view that displays color well segments side by side.
internal class ColorWellLayoutView: NSGridView {
    /// A segment that displays a color swatch with the color well's
    /// current color selection.
    let swatchSegment: SwatchSegment

    /// A segment that, when pressed, opens the color well's color panel.
    let toggleSegment: ToggleSegment

    private var row: NSGridRow?

    /// This layer helps the color well mimic the appearance of a native
    /// macOS UI element by drawing a small bezel around the edge of the view.
    private var bezelLayer: CAGradientLayer?

    private var observations = Set<NSKeyValueObservation>()

    /// Creates a grid view with the given color well.
    init(colorWell: ColorWell) {
        swatchSegment = SwatchSegment(colorWell: colorWell)
        toggleSegment = ToggleSegment(colorWell: colorWell)

        super.init(frame: .zero)

        wantsLayer = true
        columnSpacing = 0
        xPlacement = .fill
        yPlacement = .fill

        colorWell.observe(\.style, options: [.initial, .new]) { [weak self] colorWell, _ in
            self?.setRow(for: colorWell.style)
        }
        .store(in: &observations)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Instance Methods
extension ColorWellLayoutView {
    func removeRow(_ row: NSGridRow) {
        for n in 0..<row.numberOfCells {
            row.cell(at: n).contentView?.removeFromSuperview()
        }
        removeRow(at: index(of: row))
    }

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
}

// MARK: Overrides
extension ColorWellLayoutView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        bezelLayer?.removeFromSuperlayer()

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
