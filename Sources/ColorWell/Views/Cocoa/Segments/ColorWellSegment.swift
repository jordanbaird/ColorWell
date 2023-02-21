//===----------------------------------------------------------------------===//
//
// ColorWellSegment.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

// MARK: - ColorWellSegment

internal class ColorWellSegment: NSView {
    weak var colorWell: ColorWell?

    private var shadowLayer: CALayer?

    private var trackingArea: NSTrackingArea?

    /// The accumulated offset of the current series of dragging events.
    private var draggingOffset = CGSize()

    var cachedDefaultPath = CachedPath<NSBezierPath>()

    var cachedShadowPath = CachedPath<CGPath>()

    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// A Boolean value that indicates whether the current dragging event,
    /// if any, is valid for starting a dragging session.
    var isValidDrag: Bool {
        max(abs(draggingOffset.width), abs(draggingOffset.height)) >= 2
    }

    var state = State.default {
        didSet {
            switch oldValue {
            case .hover:
                removeHoverIndicator()
            case .highlight:
                removeHighlightIndicator()
            case .pressed:
                removePressedIndicator()
            case .default:
                break
            }
            switch state {
            case .hover:
                drawHoverIndicator()
            case .highlight:
                drawHighlightIndicator()
            case .pressed:
                drawPressedIndicator()
            case .default:
                break
            }
            needsDisplay = true
        }
    }

    /// The side of the color well that this segment is on.
    var side: Side { .null }

    /// A Boolean value that indicates whether the color well is enabled.
    var colorWellIsEnabled: Bool {
        colorWell?.isEnabled ?? false
    }

    /// The default fill color of the segment.
    var defaultFillColor: NSColor { .controlColor }

    var defaultDisplayColor: NSColor {
        if colorWellIsEnabled {
            return defaultFillColor
        } else {
            let disabledAlpha = max(defaultFillColor.alphaComponent - 0.5, 0.1)
            return defaultFillColor.withAlphaComponent(disabledAlpha)
        }
    }

    /// The unaltered fill color of the segment. Setting this value
    /// automatically redraws the segment.
    lazy var fillColor = defaultFillColor {
        didSet {
            needsDisplay = true
        }
    }

    /// The color that is displayed directly in the segment, altered
    /// from `fillColor` to reflect whether the color well is currently
    /// enabled or disabled.
    var displayColor: NSColor {
        if colorWellIsEnabled {
            return fillColor
        } else {
            let disabledAlpha = max(fillColor.alphaComponent - 0.5, 0.1)
            return fillColor.withAlphaComponent(disabledAlpha)
        }
    }

    /// Creates a segment for the given color well.
    init(colorWell: ColorWell) {
        super.init(frame: .zero)
        self.colorWell = colorWell
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ColorWellSegment Dynamic Methods

    /// Invoked to update the segment to indicate that it is
    /// being hovered over.
    @objc dynamic
    func drawHoverIndicator() {
        needsDisplay = true
    }

    /// Invoked to update the segment to indicate that is is
    /// not being hovered over.
    @objc dynamic
    func removeHoverIndicator() {
        needsDisplay = true
    }

    /// Invoked to update the segment to indicate that it is
    /// being highlighted.
    @objc dynamic
    func drawHighlightIndicator() {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            fillColor = defaultFillColor.withAlphaComponent(defaultFillColor.alphaComponent + 0.1)
        } else if let blended = defaultFillColor.blended(withFraction: 0.5, of: .selectedControlColor) {
            fillColor = blended
        } else {
            fillColor = .selectedControlColor
        }
    }

    /// Invoked to update the segment to indicate that it is
    /// not being highlighted.
    @objc dynamic
    func removeHighlightIndicator() {
        fillColor = defaultFillColor
    }

    /// Invoked to update the segment to indicate that it is
    /// being pressed.
    @objc dynamic
    func drawPressedIndicator() {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            fillColor = defaultFillColor.withAlphaComponent(defaultFillColor.alphaComponent + 0.25)
        } else {
            fillColor = .selectedControlColor
        }
    }

    /// Invoked to update the segment to indicate that it is
    /// not being pressed.
    @objc dynamic
    func removePressedIndicator() {
        fillColor = defaultFillColor
    }

    /// Invoked to perform the segment's action.
    @objc dynamic
    func performAction() { }
}

// MARK: ColorWellSegment Private Methods
extension ColorWellSegment {
    /// Updates the segment's dragging offset according to the x and y
    /// deltas of the given event.
    private func updateDraggingOffset(with event: NSEvent) {
        draggingOffset.width += event.deltaX
        draggingOffset.height += event.deltaY
    }
}

// MARK: ColorWellSegment Internal Methods
extension ColorWellSegment {
    /// Returns the default path that will be used to draw the segment.
    func updateCachedPath<Path: ConstructablePath>(for rect: NSRect, cached: inout CachedPath<Path>) {
        if cached.rect != rect {
            switch colorWell?.style {
            case .swatches, .colorPanel:
                cached = CachedPath(rect: rect, side: nil)
            default:
                cached = CachedPath(rect: rect, side: side)
            }
        }
    }

    func addShadowLayer(for rect: NSRect) {
        shadowLayer?.removeFromSuperlayer()
        shadowLayer = nil

        guard let layer else {
            return
        }

        let shadowLayer = CALayer()

        let shadowOffset = NSSize(width: 0, height: 0)
        let shadowRadius = Constants.lineWidth * 0.75

        updateCachedPath(for: rect, cached: &cachedShadowPath)

        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = NSApp.effectiveAppearanceIsDarkAppearance ? 0.5 : 0.6
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowPath = cachedShadowPath.path
        shadowLayer.shadowColor = NSColor.shadowColor.cgColor

        let mutablePath = CGMutablePath()
        mutablePath.addRect(
            rect.insetBy(
                dx: -(shadowRadius * 2) + shadowOffset.width,
                dy: -(shadowRadius * 2) + shadowOffset.height
            )
        )
        mutablePath.addPath(cachedShadowPath.path)
        mutablePath.closeSubpath()

        let maskLayer = CAShapeLayer()
        maskLayer.path = mutablePath
        maskLayer.fillRule = .evenOdd

        shadowLayer.mask = maskLayer

        layer.addSublayer(shadowLayer)
        layer.masksToBounds = false

        self.shadowLayer = shadowLayer
    }
}

// MARK: ColorWellSegment Overrides
extension ColorWellSegment {
    override func draw(_ dirtyRect: NSRect) {
        updateCachedPath(for: dirtyRect, cached: &cachedDefaultPath)
        displayColor.setFill()
        cachedDefaultPath.path.fill()
        addShadowLayer(for: dirtyRect)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard colorWellIsEnabled else {
            return
        }
        if state == .default {
            state = .hover
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard colorWellIsEnabled else {
            return
        }
        if state == .hover {
            state = .default
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard colorWellIsEnabled else {
            return
        }
        state = .highlight
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        draggingOffset = .zero
        guard
            colorWellIsEnabled,
            frameConvertedToWindow.contains(event.locationInWindow)
        else {
            return
        }
        performAction()
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard colorWellIsEnabled else {
            return
        }

        updateDraggingOffset(with: event)

        guard
            !isActive,
            isValidDrag
        else {
            return
        }

        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else {
            state = .default
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

// MARK: ColorWellSegment Accessibility
extension ColorWellSegment {
    override func accessibilityParent() -> Any? {
        colorWell
    }

    override func accessibilityPerformPress() -> Bool {
        performAction()
        return true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override func isAccessibilityElement() -> Bool {
        true
    }
}

// MARK: - ColorWellSegment State

extension ColorWellSegment {
    /// A type that represents the state of a color well segment.
    enum State {
        case hover
        case highlight
        case pressed
        case `default`
    }
}
