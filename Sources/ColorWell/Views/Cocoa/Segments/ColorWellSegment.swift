//
// ColorWellSegment.swift
// ColorWell
//

import Cocoa

/// A view that draws a segmented portion of a color well.
class ColorWellSegment: NSView {

    // MARK: Properties

    weak var colorWell: ColorWell?

    weak var layoutView: ColorWellLayoutView?

    private let shadowRadius = 0.75

    private let shadowOffset = CGSize(width: 0, height: -0.25)

    private var shadowLayer: CALayer?

    /// The segment's cached values.
    let caches = (
        segmentPath: Cache(NSBezierPath(), id: NSRect()),
        shadowPath: Cache(CGMutablePath() as CGPath, id: NSRect()),
        maskPath: Cache(CGMutablePath() as CGPath, id: NSRect())
    )

    /// The segment's current and previous states.
    var backingStates: (current: State, previous: State) = (.default, .default)

    /// The segment's current state.
    var state: State {
        get {
            backingStates.current
        }
        set {
            backingStates = (newValue, state)
            if needsDisplayOnStateChange(newValue) {
                needsDisplay = true
            }
        }
    }

    /// A Boolean value that indicates whether the segment's
    /// color well is active.
    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// A Boolean value that indicates whether the segment's
    /// color well is enabled.
    var isEnabled: Bool {
        colorWell?.isEnabled ?? false
    }

    /// The side containing this segment in its color well.
    var side: Side { .null }

    /// The unaltered fill color of the segment.
    var rawColor: NSColor { .colorWellSegmentColor }

    /// The color that is displayed directly in the segment.
    var displayColor: NSColor { rawColor }

    // MARK: Initializers

    /// Creates a segment for the given color well and layout view.
    init?(colorWell: ColorWell?, layoutView: ColorWellLayoutView?) {
        guard
            let colorWell,
            let layoutView
        else {
            return nil
        }
        super.init(frame: .zero)
        self.colorWell = colorWell
        self.layoutView = layoutView
        wantsLayer = true
        updateCachedPathConstructors()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Dynamic Class Methods

    /// Invoked to perform a color well segment's action.
    @objc dynamic
    class func performAction(for segment: ColorWellSegment) -> Bool { false }

    // MARK: Dynamic Instance Methods

    /// Invoked to return whether the segment should be redrawn
    /// after its state changes.
    @objc dynamic
    func needsDisplayOnStateChange(_ state: State) -> Bool { false }
}

// MARK: Private Instance Methods
extension ColorWellSegment {
    private func updateCachedPathConstructors() {
        caches.segmentPath.updateConstructor { [weak self] bounds in
            guard let self else {
                return NSBezierPath()
            }
            return .colorWellSegment(rect: bounds, side: self.side)
        }

        caches.shadowPath.updateConstructor { [weak self] bounds in
            guard let self else {
                return CGMutablePath()
            }
            return .colorWellSegment(rect: bounds, side: self.side)
        }

        caches.maskPath.updateConstructor { [weak self] bounds in
            guard let self else {
                return CGMutablePath()
            }
            let maskPath = CGMutablePath()
            maskPath.addRect(
                bounds.insetBy(
                    dx: -(self.shadowRadius * 2) + self.shadowOffset.width,
                    dy: -(self.shadowRadius * 2) + self.shadowOffset.height
                )
            )
            maskPath.addPath(self.caches.shadowPath.cachedValue)
            maskPath.closeSubpath()
            return maskPath
        }
    }
}

// MARK: Internal Instance Methods
extension ColorWellSegment {
    /// Performs the segment's action.
    func performAction() -> Bool {
        Self.performAction(for: self)
    }

    /// Updates the shadow layer for the specified rectangle.
    func updateShadowLayer(_ dirtyRect: NSRect) {
        shadowLayer?.removeFromSuperlayer()
        shadowLayer = nil

        guard let layer else {
            return
        }

        caches.shadowPath.recache(id: dirtyRect)
        caches.maskPath.recache(id: dirtyRect)

        let maskLayer = CAShapeLayer()
        maskLayer.path = caches.maskPath.cachedValue
        maskLayer.fillRule = .evenOdd

        let shadowLayer = CALayer()
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowPath = caches.shadowPath.cachedValue
        shadowLayer.shadowOpacity = 0.5
        shadowLayer.mask = maskLayer

        layer.masksToBounds = false
        layer.addSublayer(shadowLayer)

        self.shadowLayer = shadowLayer
    }
}

// MARK: Overrides
extension ColorWellSegment {
    override func draw(_ dirtyRect: NSRect) {
        displayColor.setFill()
        caches.segmentPath.recache(id: dirtyRect)
        caches.segmentPath.cachedValue.fill()
        updateShadowLayer(dirtyRect)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard isEnabled else {
            return
        }
        state = .highlight
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard
            isEnabled,
            frameConvertedToWindow.contains(event.locationInWindow)
        else {
            return
        }
        _ = performAction()
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
    @objc enum State: Int {
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
