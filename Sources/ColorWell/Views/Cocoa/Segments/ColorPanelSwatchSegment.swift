//
// ColorPanelSwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection, and that toggles the color panel
/// when pressed.
class ColorPanelSwatchSegment: SwatchSegment {
    /// The cached path for the segment's swatch.
    private let cachedSwatchPath = Cache(NSBezierPath(), id: NSRect())

    var bezelColor: NSColor {
        let bezelColor: NSColor

        switch state {
        case .highlight, .pressed:
            if NSApp.effectiveAppearanceIsDarkAppearance {
                bezelColor = .highlightColor
            } else {
                bezelColor = .selectedColorWellSegmentColor
            }
        default:
            bezelColor = .colorWellSegmentColor
        }

        guard isEnabled else {
            let alphaComponent = max(bezelColor.alphaComponent - 0.5, 0.1)
            return bezelColor.withAlphaComponent(alphaComponent)
        }

        return bezelColor
    }

    override var side: Side { .null }

    override init?(colorWell: ColorWell?, layoutView: ColorWellLayoutView?) {
        super.init(colorWell: colorWell, layoutView: layoutView)
        cachedSwatchPath.updateConstructor { bounds in
            NSBezierPath(
                roundedRect: bounds.insetBy(dx: 3, dy: 3),
                xRadius: 2,
                yRadius: 2
            )
        }
    }
}

// MARK: Perform Action
extension ColorPanelSwatchSegment {
    override class func performAction(for segment: ColorWellSegment) -> Bool {
        ToggleSegment.performAction(for: segment)
    }
}

// MARK: Overrides
extension ColorPanelSwatchSegment {
    override func drawSwatch(_ dirtyRect: NSRect) {
        bezelColor.setFill()
        caches.segmentPath.recache(id: dirtyRect)
        caches.segmentPath.cachedValue.fill()

        cachedSwatchPath.recache(id: dirtyRect)

        cachedSwatchPath.cachedValue.addClip()
        displayColor.drawSwatch(in: dirtyRect)

        borderColor.setStroke()
        cachedSwatchPath.cachedValue.stroke()
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .highlight, .pressed, .default:
            return true
        case .hover:
            return false
        }
    }
}
