//
// ColorPanelSwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection, and that toggles the color panel
/// when pressed.
class ColorPanelSwatchSegment: SwatchSegment {
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
        defaultPath(dirtyRect).fill()

        let swatchPath = NSBezierPath(
            roundedRect: dirtyRect.insetBy(dx: 3, dy: 3),
            xRadius: 2,
            yRadius: 2
        )

        swatchPath.addClip()
        displayColor.drawSwatch(in: dirtyRect)

        borderColor.setStroke()
        swatchPath.stroke()
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
