//
// ColorWellBorderedSwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection, and that toggles the color panel
/// when pressed.
class ColorWellBorderedSwatchSegment: ColorWellSwatchSegment {

    // MARK: Properties

    private let cachedSwatchPath = Cache(NSBezierPath(), id: NSRect())

    var bezelColor: NSColor {
        let bezelColor: NSColor

        switch state {
        case .highlight, .pressed:
            switch DrawingStyle.current {
            case .dark:
                bezelColor = .highlightColor
            case .light:
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

    // MARK: Initializers

    override init?(colorWell: ColorWell?) {
        super.init(colorWell: colorWell)
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
extension ColorWellBorderedSwatchSegment {
    override class func performAction(for segment: ColorWellSegment) -> Bool {
        ColorWellToggleSegment.performAction(for: segment)
    }
}

// MARK: Overrides
extension ColorWellBorderedSwatchSegment {
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
