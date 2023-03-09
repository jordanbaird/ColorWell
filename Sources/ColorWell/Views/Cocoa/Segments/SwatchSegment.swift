//
// SwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection.
class SwatchSegment: ColorWellSegment {
    /// A Boolean value that indicates whether the clicking
    /// the segment can show the popover.
    private var canShowPopover = false

    /// A Boolean value that, if true, overrides the current
    /// value of `canShowPopover`.
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

    override var side: Side { .left }

    override var fillColor: NSColor {
        colorWell?.color ?? super.fillColor
    }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.sRGB) ?? super.displayColor
    }

    override init?(colorWell: ColorWell?) {
        super.init(colorWell: colorWell)
        registerForDraggedTypes([.color])
    }
}

// MARK: Instance Methods
extension SwatchSegment {
    /// Invoked when the segment is about to perform its action.
    private func prepareForAction() {
        guard let colorWell else {
            canShowPopover = false
            return
        }

        guard !shouldOverrideShowPopover else {
            return
        }

        canShowPopover = colorWell.popoverContext == nil
    }

    /// Creates the popover, showing it at the bottom edge of
    /// the segment's frame.
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

    func action(forStyle style: ColorWell.Style?) -> () -> Bool {
        switch style {
        case .expanded, .swatches:
            return { [weak self] in
                guard let self else {
                    return false
                }
                self.prepareForAction()
                if self.shouldOverrideShowPopover {
                    let action = self.action(forStyle: .colorPanel)
                    return action()
                } else if self.canShowPopover {
                    self.makeAndShowPopover()
                    return true
                }
                return false
            }
        case .colorPanel:
            return { [weak colorWell] in
                guard let colorWell else {
                    return false
                }
                if colorWell.isActive {
                    colorWell.deactivate()
                } else {
                    colorWell.activateAutoVerifyingExclusive()
                }
                return true
            }
        case .none:
            return { false }
        }
    }

    /// Draws the segment's swatch in the given rectangle.
    private func drawSwatch(_ dirtyRect: NSRect) {
        guard let colorWell else {
            return
        }

        NSGraphicsContext.withCachedGraphicsState {
            updateCachedPath(for: dirtyRect, cached: &defaultPath)
            switch colorWell.style {
            case .expanded, .swatches:
                NSImage.drawSwatch(
                    with: displayColor,
                    in: dirtyRect,
                    clippingTo: defaultPath.path
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
                defaultPath.path.fill()

                NSImage.drawSwatch(
                    with: displayColor,
                    in: dirtyRect,
                    clippingTo: NSBezierPath(
                        roundedRect: dirtyRect.insetBy(dx: 3, dy: 3),
                        xRadius: 2,
                        yRadius: 2
                    )
                )
            }
        }
    }

    /// Draws the segment's border in the given rectangle.
    private func drawBorder(_ dirtyRect: NSRect) {
        struct BorderStorage {
            private static let storage = Storage(variant: ObjectIdentifier(Self.self))

            let segment: SwatchSegment

            let dirtyRect: NSRect

            private var borderPath: CachedPath<NSBezierPath> {
                get {
                    Self.storage.value(forObject: segment, default: CachedPath())
                }
                nonmutating set {
                    Self.storage.set(newValue, forObject: segment)
                }
            }

            private var borderColor: NSColor {
                let displayColor = segment.displayColor
                let normalizedBrightness = min(displayColor.averageBrightness, displayColor.alphaComponent)
                let alpha = min(normalizedBrightness, 0.2)
                return NSColor(white: 1 - alpha, alpha: alpha)
            }

            func drawBorder() {
                NSGraphicsContext.withCachedGraphicsState {
                    let lineWidth = ColorWell.lineWidth

                    segment.updateCachedPath(
                        for: dirtyRect.insetBy(dx: lineWidth / 4, dy: lineWidth / 2),
                        cached: &borderPath
                    )

                    if segment.colorWell?.style != .colorPanel {
                        borderColor.setStroke()
                        borderPath.path.lineWidth = lineWidth
                        borderPath.path.stroke()
                    }
                }
            }
        }

        BorderStorage(segment: self, dirtyRect: dirtyRect).drawBorder()
    }

    /// Draws a downward-facing caret inside the segment's layer.
    ///
    /// This method is invoked when the mouse pointer is inside
    /// the bounds of the segment.
    private func drawCaret(_ dirtyRect: NSRect) {
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

// MARK: Overrides
extension SwatchSegment {
    override func draw(_ dirtyRect: NSRect) {
        guard colorWellIsEnabled else {
            super.draw(dirtyRect)
            return
        }

        drawSwatch(dirtyRect)

        if state == .hover {
            drawCaret(dirtyRect)
        }

        drawBorder(dirtyRect)
        updateShadowLayer(dirtyRect)
    }

    override func drawHoverIndicator() -> Bool { true }

    override func removeHoverIndicator() -> Bool { true }

    override func performAction() -> Bool {
        let action = action(forStyle: colorWell?.style)
        return action()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard colorWellIsEnabled else {
            return
        }
        state = .hover
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard colorWellIsEnabled else {
            return
        }
        state = .default
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
            draggingInformation.isValid,
            let color = colorWell?.color
        else {
            return
        }

        state = .default

        let colorForDragging = color.createArchivedCopy()
        NSColorPanel.dragColor(colorForDragging, with: event, from: self)
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

// MARK: Accessibility
extension SwatchSegment {
    override func isAccessibilityElement() -> Bool {
        false
    }
}
