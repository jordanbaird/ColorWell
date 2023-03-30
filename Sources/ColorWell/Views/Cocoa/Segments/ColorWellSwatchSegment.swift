//
// ColorWellSwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection.
class ColorWellSwatchSegment: ColorWellSegment {

    // MARK: Properties

    var draggingInformation = DraggingInformation()

    var borderColor: NSColor {
        let displayColor = displayColor
        let normalizedBrightness = min(displayColor.averageBrightness, displayColor.alphaComponent)
        let alpha = min(normalizedBrightness, 0.2)
        return NSColor(white: 1 - alpha, alpha: alpha)
    }

    override var rawColor: NSColor {
        colorWell?.color ?? super.rawColor
    }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.displayP3) ?? super.displayColor
    }

    // MARK: Initializers

    override init?(colorWell: ColorWell?) {
        super.init(colorWell: colorWell)
        registerForDraggedTypes([.color])
    }
}

// MARK: Instance Methods
extension ColorWellSwatchSegment {
    /// Draws the segment's swatch in the specified rectangle.
    @objc dynamic
    func drawSwatch(_ dirtyRect: NSRect) {
        caches.segmentPath.recache(id: dirtyRect)
        NSImage.drawSwatch(
            with: displayColor,
            in: dirtyRect,
            clippingTo: caches.segmentPath.cachedValue
        )
    }
}

// MARK: Overrides
extension ColorWellSwatchSegment {
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
        state = backingStates.previous

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
extension ColorWellSwatchSegment {
    override func isAccessibilityElement() -> Bool {
        false
    }
}
