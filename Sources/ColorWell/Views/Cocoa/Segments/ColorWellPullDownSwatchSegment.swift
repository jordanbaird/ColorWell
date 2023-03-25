//
// ColorWellPullDownSwatchSegment.swift
// ColorWell
//

import Cocoa

/// A segment that displays a color swatch with the color well's
/// current color selection, and that triggers a pull down action
/// when pressed.
class ColorWellPullDownSwatchSegment: ColorWellSwatchSegment {

    // MARK: Properties

    /// A tracking area for mouse enter/exit events.
    private var trackingArea: NSTrackingArea?

    /// The cached path for the segment's border.
    private let cachedBorderPath = Cache(NSBezierPath(), id: NSRect())

    /// The cached paths for the segment's caret.
    private let cachedCaretPaths = Cache((caret: NSBezierPath(), backing: NSBezierPath()), id: NSRect())

    /// A Boolean value that indicates whether the segment
    /// fills its color well.
    ///
    /// If this segment is the only segment in its layout view,
    /// the return value is `true`. If the layout view contains
    /// additional segments, the return value is `false`.
    var isFullSegment: Bool {
        guard let layoutView = colorWell?.layoutView else {
            return false
        }
        return layoutView.currentSegments == [self]
    }

    /// A Boolean value indicating whether the segment can perform
    /// its pull down action.
    var canPullDown: Bool {
        guard let colorWell else {
            return false
        }
        return !colorWell.swatchColors.isEmpty
    }

    override var side: Side {
        isFullSegment ? .null : .left
    }

    override var draggingInformation: DraggingInformation {
        didSet {
            // Hack to ensure the caret disappears when dragging starts.
            if draggingInformation.isDragging {
                state = .default
            }
        }
    }

    // MARK: Initializers

    override init?(colorWell: ColorWell?) {
        super.init(colorWell: colorWell)

        cachedBorderPath.updateConstructor { [weak self] bounds in
            guard let self else {
                return NSBezierPath()
            }
            let lineWidth = ColorWell.lineWidth
            let path = NSBezierPath.colorWellSegment(
                rect: bounds.insetBy(
                    dx: lineWidth / 4,
                    dy: lineWidth / 2
                ),
                side: self.side
            )
            path.lineWidth = lineWidth
            return path
        }

        cachedCaretPaths.updateConstructor { bounds in
            let lineWidth = 1.5

            let caretSize = NSSize(width: 12, height: 12)
            let caretBounds = NSRect(
                origin: NSPoint(
                    x: bounds.maxX - caretSize.width - 4,
                    y: bounds.midY - caretSize.height / 2
                ),
                size: caretSize
            )
            let caretPathBounds = NSRect(
                x: 0,
                y: 0,
                width: (caretSize.width - lineWidth) / 2,
                height: (caretSize.height - lineWidth) / 4
            ).centered(
                in: caretBounds
            ).offsetBy(
                dx: 0,
                dy: -lineWidth / 4
            )

            let caretPath = NSBezierPath()

            caretPath.lineWidth = lineWidth
            caretPath.lineCapStyle = .round

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

            return (caretPath, NSBezierPath(ovalIn: caretBounds))
        }
    }
}

// MARK: Static Methods
extension ColorWellPullDownSwatchSegment {
    /// Returns a Boolean value indicating whether the specified
    /// segment can perform its pull down action.
    static func canPullDown(for segment: ColorWellSegment) -> Bool {
        guard let segment = segment as? Self else {
            return true
        }
        return segment.canPullDown
    }
}

// MARK: Instance Methods
extension ColorWellPullDownSwatchSegment {
    /// Draws the segment's border in the given rectangle.
    private func drawBorder(_ dirtyRect: NSRect) {
        NSGraphicsContext.withCachedGraphicsState {
            cachedBorderPath.recache(id: dirtyRect)
            borderColor.setStroke()
            cachedBorderPath.cachedValue.stroke()
        }
    }

    /// Draws a downward-facing caret inside the segment's layer.
    ///
    /// This method is invoked when the mouse pointer is inside
    /// the bounds of the segment.
    private func drawCaret(_ dirtyRect: NSRect) {
        guard canPullDown else {
            return
        }

        NSGraphicsContext.withCachedGraphicsState {
            cachedCaretPaths.recache(id: dirtyRect)

            let paths = cachedCaretPaths.cachedValue

            NSColor(white: 0, alpha: 0.25).setFill()
            paths.backing.fill()

            NSColor.white.setStroke()
            paths.caret.stroke()
        }
    }
}

// MARK: Perform Action
extension ColorWellPullDownSwatchSegment {
    override class func performAction(for segment: ColorWellSegment) -> Bool {
        guard
            !NSEvent.modifierFlags.contains(.shift),
            canPullDown(for: segment),
            let colorWell = segment.colorWell
        else {
            return ColorWellToggleSegment.performAction(for: segment)
        }

        let popoverContext = ColorWellPopoverContext(colorWell: colorWell)
        colorWell.popoverContext = popoverContext
        popoverContext.popover.show(relativeTo: segment.frame, of: segment, preferredEdge: .minY)

        return true
    }
}

// MARK: Overrides
extension ColorWellPullDownSwatchSegment {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawBorder(dirtyRect)
        if state == .hover {
            drawCaret(dirtyRect)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard isEnabled else {
            return
        }
        state = .hover
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard isEnabled else {
            return
        }
        state = .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .hover, .default:
            return true
        case .highlight, .pressed:
            return false
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [
                .activeInKeyWindow,
                .mouseEnteredAndExited,
            ],
            owner: self
        )
        addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
    }
}
