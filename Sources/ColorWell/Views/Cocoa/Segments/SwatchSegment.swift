//
// SwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection.
class SwatchSegment: ColorWellSegment {
    var draggingInformation = DraggingInformation()

    var borderColor: NSColor {
        let colorForDisplay = colorForDisplay
        let normalizedBrightness = min(colorForDisplay.averageBrightness, colorForDisplay.alphaComponent)
        let alpha = min(normalizedBrightness, 0.2)
        return NSColor(white: 1 - alpha, alpha: alpha)
    }

    override var rawColor: NSColor {
        colorWell?.color ?? super.rawColor
    }

    override var colorForDisplay: NSColor {
        super.colorForDisplay.usingColorSpace(.sRGB) ?? super.colorForDisplay
    }

    override init?(colorWell: ColorWell?, layoutView: ColorWellLayoutView?) {
        super.init(colorWell: colorWell, layoutView: layoutView)
        registerForDraggedTypes([.color])
    }
}

// MARK: Instance Methods
extension SwatchSegment {
    /// Draws the segment's swatch in the specified rectangle.
    @objc dynamic
    func drawSwatch(_ dirtyRect: NSRect) {
        NSImage.drawSwatch(
            with: colorForDisplay,
            in: dirtyRect,
            clippingTo: defaultPath(dirtyRect)
        )
    }
}

// MARK: Overrides
extension SwatchSegment {
    override func draw(_ dirtyRect: NSRect) {
        drawSwatch(dirtyRect)
        updateShadowLayer(dirtyRect)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        draggingInformation.reset()
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            draggingInformation.reset()
        }
        guard !draggingInformation.isDragging else {
            return
        }
        super.mouseUp(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard isEnabled else {
            return
        }

        draggingInformation.updateOffset(with: event)

        guard
            draggingInformation.isValid,
            let color = colorWell?.color
        else {
            return
        }

        draggingInformation.isDragging = true
        state = .default

        let colorForDragging = color.createArchivedCopy()
        NSColorPanel.dragColor(colorForDragging, with: event, from: self)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard
            isEnabled,
            let types = sender.draggingPasteboard.types,
            types.contains(where: { registeredDraggedTypes.contains($0) })
        else {
            return []
        }
        return .move
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if
            let colorWell,
            let color = NSColor(from: sender.draggingPasteboard)
        {
            colorWell.color = color
            return true
        }
        return false
    }
}

// MARK: Accessibility
extension SwatchSegment {
    override func isAccessibilityElement() -> Bool {
        false
    }
}
