//
// ColorPanelSwatchSegment.swift
// ColorWell
//

import Cocoa

class ColorPanelSwatchSegment: SwatchSegment {
    var bezelColor: NSColor {
        switch state {
        case .highlight, .pressed:
            if NSApp.effectiveAppearanceIsDarkAppearance {
                return .highlightColor
            } else {
                return .selectedColorWellSegmentColor
            }
        default:
            return .colorWellSegmentColor
        }
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
        colorForDisplay.drawSwatch(in: dirtyRect)

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
