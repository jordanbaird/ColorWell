//
// ColorWellSegment.swift
// ColorWell
//

import Cocoa

/// A view that draws a segmented portion of a color well.
class ColorWellSegment: NSView {
    /// The segment's color well.
    weak var colorWell: ColorWell?

    /// A tracking area for tracking mouse enter/exit events.
    private var trackingArea: NSTrackingArea?

    /// The current dragging information associated with the segment.
    var draggingInformation = DraggingInformation()

    /// The cached default drawing path of the segment.
    var defaultPath = CachedPath<NSBezierPath>()

    /// Whether the segment's color well is currently active.
    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// The segment's current state.
    var state = State.default {
        didSet {
            var needsDisplay = (oldValue: false, newValue: false)
            switch oldValue {
            case .hover:
                needsDisplay.oldValue = removeHoverIndicator()
            case .highlight:
                needsDisplay.oldValue = removeHighlightIndicator()
            case .pressed:
                needsDisplay.oldValue = removePressedIndicator()
            case .default:
                needsDisplay.oldValue = true
            }
            switch state {
            case .hover:
                needsDisplay.newValue = drawHoverIndicator()
            case .highlight:
                needsDisplay.newValue = drawHighlightIndicator()
            case .pressed:
                needsDisplay.newValue = drawPressedIndicator()
            case .default:
                needsDisplay.newValue = true
            }
            if needsDisplay.oldValue || needsDisplay.newValue {
                self.needsDisplay = true
            }
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
    var fillColorGetter: () -> NSColor {
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
    func drawHoverIndicator() -> Bool { false }

    /// Invoked to update the segment to indicate that it is
    /// not being hovered over.
    @objc dynamic
    func removeHoverIndicator() -> Bool { false }

    /// Invoked to update the segment to indicate that it is
    /// being highlighted.
    @objc dynamic
    func drawHighlightIndicator() -> Bool { false }

    /// Invoked to update the segment to indicate that it is
    /// not being highlighted.
    @objc dynamic
    func removeHighlightIndicator() -> Bool { false }

    /// Invoked to update the segment to indicate that it is
    /// being pressed.
    @objc dynamic
    func drawPressedIndicator() -> Bool { false }

    /// Invoked to update the segment to indicate that it is
    /// not being pressed.
    @objc dynamic
    func removePressedIndicator() -> Bool { false }

    /// Invoked to perform the segment's action.
    @objc dynamic
    func performAction() -> Bool { false }
}

// MARK: Internal Instance Methods
extension ColorWellSegment {
    /// Updates the cached path for the specified rectangle,
    /// depending on the style of the segment's color well.
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

    /// Updates the shadow layer for the specified rectangle.
    func updateShadowLayer(_ dirtyRect: NSRect) {
        struct ShadowLayerStorage {
            private static let storage = Storage(variant: ObjectIdentifier(Self.self))

            let segment: ColorWellSegment

            let dirtyRect: NSRect

            private var shadowLayer: CALayer? {
                get {
                    Self.storage.value(forObject: segment)
                }
                nonmutating set {
                    shadowLayer?.removeFromSuperlayer()
                    Self.storage.set(newValue, forObject: segment)
                }
            }

            var cachedShadowPath: CachedPath<CGPath> {
                get {
                    Self.storage.value(forObject: segment, default: CachedPath())
                }
                nonmutating set {
                    Self.storage.set(newValue, forObject: segment)
                }
            }

            func updateShadowLayer() {
                shadowLayer = nil

                guard let segmentLayer = segment.layer else {
                    return
                }

                segment.updateCachedPath(for: dirtyRect, cached: &cachedShadowPath)

                let shadowRadius = 0.75
                let shadowOffset = CGSize(width: 0, height: -0.25)

                let shadowLayer = CALayer()
                shadowLayer.shadowRadius = shadowRadius
                shadowLayer.shadowOffset = shadowOffset
                shadowLayer.shadowPath = cachedShadowPath.path
                shadowLayer.shadowOpacity = 0.5

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

                segmentLayer.masksToBounds = false
                segmentLayer.addSublayer(shadowLayer)

                self.shadowLayer = shadowLayer
            }
        }

        ShadowLayerStorage(segment: self, dirtyRect: dirtyRect).updateShadowLayer()
    }
}

// MARK: Overrides
extension ColorWellSegment {
    override func draw(_ dirtyRect: NSRect) {
        updateCachedPath(for: dirtyRect, cached: &defaultPath)
        displayColor.setFill()
        defaultPath.path.fill()
        updateShadowLayer(dirtyRect)
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

        guard draggingInformation.isValid else {
            return
        }

        draggingInformation.isDragging = true

        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else if isActive {
            state = .pressed
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
