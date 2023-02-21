//===----------------------------------------------------------------------===//
//
// SwatchSegment.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

// MARK: - SwatchSegment

internal class SwatchSegment: ColorWellSegment {
    private var cachedBorderPath = CachedPath<NSBezierPath>()

    private var canShowPopover = false

    private var shouldOverrideShowPopover: Bool {
        guard let colorWell else {
            return false
        }
        switch colorWell.style {
        case .expanded, .swatches:
            return colorWell.swatchColors.isEmpty
        case .colorPanel:
            return true
        }
    }

    private var borderColor: NSColor {
        let displayColor = displayColor // Avoid repeated access to reduce computation overhead
        let normalizedBrightness = min(displayColor.averageBrightness, displayColor.alphaComponent)
        let alpha = min(normalizedBrightness, 0.2)
        return NSColor(white: 1 - alpha, alpha: alpha)
    }

    override var side: Side { .left }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.sRGB) ?? super.displayColor
    }

    override init(colorWell: ColorWell) {
        super.init(colorWell: colorWell)
        self.fillColor = colorWell.color
        registerForDraggedTypes([.color])
    }
}

// MARK: SwatchSegment Methods
extension SwatchSegment {
    private func prepareForPopover() {
        guard let colorWell else {
            canShowPopover = false
            return
        }

        guard !shouldOverrideShowPopover else {
            return
        }

        canShowPopover = colorWell.popoverContext == nil
    }

    private func makeAndShowPopover() {
        guard let colorWell else {
            return
        }
        // Context should be nil no matter what here.
        assert(colorWell.popoverContext == nil, "Popover context should not exist yet")
        let popoverContext = ColorWellPopoverContext(colorWell: colorWell)
        colorWell.popoverContext = popoverContext
        popoverContext.popover.show(relativeTo: frame, of: self, preferredEdge: .minY)
    }

    private func drawSwatch(in dirtyRect: NSRect) {
        guard let colorWell else {
            return
        }

        NSGraphicsContext.withCachedGraphicsState {
            updateCachedPath(for: dirtyRect, cached: &cachedDefaultPath)
            switch colorWell.style {
            case .expanded, .swatches:
                NSImage.drawSwatch(
                    with: displayColor,
                    in: dirtyRect,
                    clippingTo: cachedDefaultPath.path
                )
            case .colorPanel:
                var backgroundColor = defaultDisplayColor

                if colorWellIsEnabled {
                    switch state {
                    case .highlight:
                        backgroundColor = .highlightedColorWellSegmentColor
                    case .pressed:
                        backgroundColor = .selectedColorWellSegmentColor
                    default:
                        break
                    }
                }

                backgroundColor.setFill()
                cachedDefaultPath.path.fill()

                NSImage.drawSwatch(
                    with: displayColor,
                    in: dirtyRect,
                    clippingTo: NSBezierPath(roundedRect: dirtyRect.insetBy(dx: 3, dy: 3), xRadius: 2, yRadius: 2)
                )
            }
        }
    }

    private func drawBorder(in dirtyRect: NSRect) {
        NSGraphicsContext.withCachedGraphicsState {
            let lineWidth = ColorWell.lineWidth

            updateCachedPath(
                for: dirtyRect.insetBy(dx: lineWidth / 4, dy: lineWidth / 2),
                cached: &cachedBorderPath
            )

            borderColor.setStroke()

            cachedBorderPath.path.lineWidth = lineWidth
            cachedBorderPath.path.stroke()
        }
    }

    private func drawCaret(in dirtyRect: NSRect) {
        guard !shouldOverrideShowPopover else {
            return
        }

        NSGraphicsContext.withCachedGraphicsState {
            let caretSize = NSSize(width: 12, height: 12)
            let caretBounds = NSRect(
                origin: NSPoint(
                    x: dirtyRect.maxX - caretSize.width - 4,
                    y: dirtyRect.midY - (caretSize.height / 2)
                ),
                size: caretSize
            )

            NSColor(white: 0, alpha: 0.25).setFill()
            NSBezierPath(ovalIn: caretBounds).fill()

            let lineWidth = 1.5
            let caretPathBounds = NSRect(
                x: 0,
                y: 0,
                width: (caretBounds.width - lineWidth) / 2,
                height: (caretBounds.height - lineWidth) / 4
            ).centered(
                in: caretBounds
            ).offsetBy(
                dx: 0,
                dy: -lineWidth / 4
            )

            let caretPath = NSBezierPath()
            caretPath.move(
                to: NSPoint(
                    x: caretPathBounds.minX,
                    y: caretPathBounds.maxY
                )
            )
            caretPath.line(
                to: NSPoint(
                    x: caretPathBounds.midX,
                    y: caretPathBounds.minY
                )
            )
            caretPath.line(
                to: NSPoint(
                    x: caretPathBounds.maxX,
                    y: caretPathBounds.maxY
                )
            )

            NSColor.white.setStroke()

            caretPath.lineWidth = lineWidth
            caretPath.lineCapStyle = .round
            caretPath.stroke()
        }
    }
}

// MARK: SwatchSegment Overrides
extension SwatchSegment {
    override func draw(_ dirtyRect: NSRect) {
        guard colorWellIsEnabled else {
            super.draw(dirtyRect)
            return
        }

        drawSwatch(in: dirtyRect)

        if state == .hover {
            drawCaret(in: dirtyRect)
        }

        drawBorder(in: dirtyRect)

        addShadowLayer(for: dirtyRect)
    }

    override func drawHoverIndicator() {
        needsDisplay = true
    }

    override func removeHoverIndicator() {
        needsDisplay = true
    }

    override func drawHighlightIndicator() {
        needsDisplay = true
    }

    override func removeHighlightIndicator() {
        needsDisplay = true
    }

    override func drawPressedIndicator() {
        needsDisplay = true
    }

    override func removePressedIndicator() {
        needsDisplay = true
    }

    override func performAction() {
        prepareForPopover()
        if shouldOverrideShowPopover {
            guard let colorWell else {
                return
            }
            switch colorWell.style {
            case .swatches, .expanded:
                colorWell.toggleSegment.state = .pressed
                colorWell.toggleSegment.performAction()
            case .colorPanel:
                state = .pressed
                colorWell.toggleSegment.performAction()
            }
        } else if canShowPopover {
            makeAndShowPopover()
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Ignore any subviews the segment may contain
        // (i.e. the caret view).
        frame.contains(point) ? self : nil
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard let colorWell else {
            return
        }
        switch colorWell.style {
        case .expanded, .swatches:
            state = .hover
        case .colorPanel:
            break
        }
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard
            isValidDrag,
            let color = colorWell?.color
        else {
            return
        }
        state = .default
        NSColorPanel.dragColor(color, with: event, from: self)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard
            let types = sender.draggingPasteboard.types,
            types.contains(where: { registeredDraggedTypes.contains($0) })
        else {
            return []
        }
        return .move
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let color = NSColor(from: sender.draggingPasteboard) {
            colorWell?.color = color
            return true
        }
        return false
    }
}

// MARK: SwatchSegment Accessibility
extension SwatchSegment {
    override func isAccessibilityElement() -> Bool {
        false
    }
}
