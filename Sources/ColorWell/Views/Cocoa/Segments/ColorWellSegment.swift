//
// ColorWellSegment.swift
// ColorWell
//

import Cocoa

/// A view that draws a segmented portion of a color well.
class ColorWellSegment: NSView {

    // MARK: Static Properties

    /// Storage shared between every `ColorWellSegment` instance.
    static let storage = Storage()

    // MARK: Instance Properties

    /// The segment's color well.
    weak var colorWell: ColorWell?

    /// The layer that displays the segment's shadow.
    private var shadowLayer: CALayer?

    /// A tracking area for tracking mouse enter/exit events.
    private var trackingArea: NSTrackingArea?

    /// The current dragging information associated with the segment.
    var draggingInformation: DraggingInformation {
        get { Self.storage.value(forObject: self, default: DraggingInformation()) }
        set { Self.storage.set(newValue, forObject: self) }
    }

    /// The cached default drawing path of the segment.
    var cachedDefaultPath: CachedPath<NSBezierPath> {
        get { Self.storage.value(forObject: self, default: CachedPath()) }
        set { Self.storage.set(newValue, forObject: self) }
    }

    /// The cached drawing path of the segment's shadow.
    var cachedShadowPath: CachedPath<CGPath> {
        get { Self.storage.value(forObject: self, default: CachedPath()) }
        set { Self.storage.set(newValue, forObject: self) }
    }

    /// Whether the segment's color well is currently active.
    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// The segment's current state.
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

    /// The side of the color well that this segment is drawn in.
    var side: Side { .null }

    /// A Boolean value that indicates whether the color well is enabled.
    var colorWellIsEnabled: Bool {
        colorWell?.isEnabled ?? false
    }

    /// A color that is altered from `defaultFillColor` to reflect whether
    /// the color well is currently enabled or disabled.
    var defaultDisplayColor: NSColor {
        colorWellIsEnabled ? .colorWellSegmentColor : .colorWellSegmentColor.disabled
    }

    /// A closure that provides a value for the `fillColor` property.
    ///
    /// Setting this value automatically redraws the segment.
    private var fillColorGetter: () -> NSColor {
        didSet {
            needsDisplay = true
        }
    }

    /// The unaltered fill color of the segment.
    var fillColor: NSColor {
        fillColorGetter()
    }

    /// The color that is displayed directly in the segment, altered
    /// from `fillColor` to reflect whether the color well is currently
    /// enabled or disabled.
    var displayColor: NSColor {
        colorWellIsEnabled ? fillColor : fillColor.disabled
    }

    // MARK: Initializers

    /// Creates a segment for the given color well.
    init?(colorWell: ColorWell?) {
        guard let colorWell else {
            return nil
        }
        self.fillColorGetter = { .colorWellSegmentColor }
        super.init(frame: .zero)
        self.colorWell = colorWell
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Dynamic Instance Methods

    /// Invoked to update the segment to indicate that it is
    /// being hovered over.
    @objc dynamic
    func drawHoverIndicator() {
        needsDisplay = true
    }

    /// Invoked to update the segment to indicate that it is
    /// not being hovered over.
    @objc dynamic
    func removeHoverIndicator() {
        needsDisplay = true
    }

    /// Invoked to update the segment to indicate that it is
    /// being highlighted.
    @objc dynamic
    func drawHighlightIndicator() {
        fillColorGetter = { .highlightedColorWellSegmentColor }
    }

    /// Invoked to update the segment to indicate that it is
    /// not being highlighted.
    @objc dynamic
    func removeHighlightIndicator() {
        fillColorGetter = { .colorWellSegmentColor }
    }

    /// Invoked to update the segment to indicate that it is
    /// being pressed.
    @objc dynamic
    func drawPressedIndicator() {
        fillColorGetter = { .selectedColorWellSegmentColor }
    }

    /// Invoked to update the segment to indicate that it is
    /// not being pressed.
    @objc dynamic
    func removePressedIndicator() {
        fillColorGetter = { .colorWellSegmentColor }
    }

    /// Invoked to perform the segment's action.
    @objc dynamic
    func performAction() -> Bool { false }
}

// MARK: Internal Instance Methods
extension ColorWellSegment {
    /// Returns the default path that will be used to draw the segment.
    func updateCachedPath<Path: ConstructablePath>(for rect: NSRect, cached: inout CachedPath<Path>) {
        if cached.bounds != rect {
            switch colorWell?.style {
            case .swatches, .colorPanel:
                cached = CachedPath(bounds: rect, side: nil)
            default:
                cached = CachedPath(bounds: rect, side: side)
            }
        }
    }

    /// Updates the shadow layer for the given rectangle.
    func updateShadowLayer(_ dirtyRect: NSRect) {
        shadowLayer?.removeFromSuperlayer()
        shadowLayer = nil

        guard let layer else {
            return
        }

        let shadowLayer = CALayer()

        let shadowOffset = NSSize(width: 0, height: 0)
        let shadowRadius = ColorWell.lineWidth * 0.75

        updateCachedPath(for: dirtyRect, cached: &cachedShadowPath)

        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowPath = cachedShadowPath.path
        shadowLayer.shadowColor = NSColor.shadowColor.cgColor

        let mutablePath = CGMutablePath()
        mutablePath.addRect(
            dirtyRect.insetBy(
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

// MARK: Overrides
extension ColorWellSegment {
    override func draw(_ dirtyRect: NSRect) {
        updateCachedPath(for: dirtyRect, cached: &cachedDefaultPath)
        displayColor.setFill()
        cachedDefaultPath.path.fill()
        updateShadowLayer(dirtyRect)
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
        defer {
            draggingInformation.reset()
        }
        guard colorWellIsEnabled else {
            return
        }
        state = .highlight
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        defer {
            draggingInformation.reset()
        }
        guard
            !draggingInformation.isDragging,
            colorWellIsEnabled,
            frameConvertedToWindow.contains(event.locationInWindow)
        else {
            return
        }
        _ = performAction()
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard colorWellIsEnabled else {
            return
        }

        draggingInformation.updateOffset(with: event)
        draggingInformation.isDragging = true

        guard
            !isActive,
            draggingInformation.isValid
        else {
            return
        }

        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else {
            state = .default
        }
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        super.draggingExited(sender)
        draggingInformation.offset = .zero
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

// MARK: Accessibility
extension ColorWellSegment {
    override func accessibilityParent() -> Any? {
        colorWell
    }

    override func accessibilityPerformPress() -> Bool {
        performAction()
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
        /// The segment is being hovered over.
        case hover

        /// The segment is highlighted.
        case highlight

        /// The segment is pressed.
        case pressed

        /// The default, idle state of a segment.
        case `default`
    }
}

// MARK: - ColorWellSegment DraggingInformation

extension ColorWellSegment {
    /// Dragging information associated with a color well segment.
    struct DraggingInformation {
        /// The default values for this instance.
        private let defaults: (threshold: CGFloat, isDragging: Bool, offset: CGSize)

        /// The amount of movement that must occur before a dragging
        /// session can start.
        var threshold: CGFloat

        /// A Boolean value that indicates whether a drag is currently
        /// in progress.
        var isDragging: Bool

        /// The accumulated offset of the current series of dragging
        /// events.
        var offset: CGSize

        /// A Boolean value that indicates whether the current dragging
        /// information is valid for starting a dragging session.
        var isValid: Bool {
            hypot(offset.width, offset.height) >= threshold
        }

        /// Creates an instance with the given values.
        ///
        /// The values that are provided here will be cached, and used
        /// to reset the instance.
        init(
            threshold: CGFloat = 4,
            isDragging: Bool = false,
            offset: CGSize = CGSize()
        ) {
            self.defaults = (threshold, isDragging, offset)
            self.threshold = threshold
            self.isDragging = isDragging
            self.offset = offset
        }

        /// Resets the dragging information to its default values.
        mutating func reset() {
            self = DraggingInformation(
                threshold: defaults.threshold,
                isDragging: defaults.isDragging,
                offset: defaults.offset
            )
        }

        /// Updates the segment's dragging offset according to the x and y
        /// deltas of the given event.
        mutating func updateOffset(with event: NSEvent) {
            offset.width += event.deltaX
            offset.height += event.deltaY
        }
    }
}
