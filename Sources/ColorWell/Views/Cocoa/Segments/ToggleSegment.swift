//
// ToggleSegment.swift
// ColorWell
//

import Cocoa

/// A segment that, when pressed, toggles the color panel.
class ToggleSegment: ColorWellSegment {
    static let widthConstant: CGFloat = 20

    override var side: Side { .right }

    override init?(colorWell: ColorWell?) {
        super.init(colorWell: colorWell)
        // Constraining this segment's width will force the other
        // segment to fill the remaining space.
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: Self.widthConstant).isActive = true
    }
}

// MARK: Instance Methods
extension ToggleSegment {
    /// Adds a layer that contains an image indicating that the
    /// segment toggles the color panel.
    private func updateImageLayer(_ dirtyRect: NSRect) {
        struct ImageLayerStorage {
            private static let storage = Storage(variant: ObjectIdentifier(Self.self))

            let segment: ToggleSegment

            let dirtyRect: NSRect

            private var imageLayer: CALayer? {
                get {
                    Self.storage.value(forObject: segment)
                }
                nonmutating set {
                    imageLayer?.removeFromSuperlayer()
                    Self.storage.set(newValue, forObject: segment)
                }
            }

            func updateImageLayer() {
                imageLayer = nil

                guard let segmentLayer = segment.layer else {
                    return
                }

                let dimension = min(dirtyRect.width, dirtyRect.height) - 5.5
                let imageLayer = CALayer()

                imageLayer.frame = NSRect(
                    x: 0,
                    y: 0,
                    width: dimension,
                    height: dimension
                ).centered(in: dirtyRect)

                // Cache the image if this is the first time we're accessing
                // it, for more efficient retrieval in the future.
                var image = Self.storage.value(forObject: segment, default: {
                    // Force unwrap is okay here, as the image is an AppKit builtin.
                    let image = NSImage(named: NSImage.touchBarColorPickerFillName)!
                    return image.clippedToSquare()
                }())

                if segment.state == .highlight {
                    image = NSApp.effectiveAppearanceIsDarkAppearance
                        ? image.tinted(to: .white, amount: 0.33)
                        : image.tinted(to: .black, amount: 0.2)
                }

                imageLayer.contents = image

                if !segment.colorWellIsEnabled {
                    imageLayer.opacity = 0.5
                }

                segmentLayer.addSublayer(imageLayer)

                self.imageLayer = imageLayer
            }
        }

        ImageLayerStorage(segment: self, dirtyRect: dirtyRect).updateImageLayer()
    }
}

// MARK: Overrides
extension ToggleSegment {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateImageLayer(dirtyRect)
    }

    override func drawHighlightIndicator() -> Bool {
        fillColorGetter = { .highlightedColorWellSegmentColor }
        return true
    }

    override func removeHighlightIndicator() -> Bool {
        fillColorGetter = { .colorWellSegmentColor }
        return true
    }

    override func drawPressedIndicator() -> Bool {
        fillColorGetter = { .selectedColorWellSegmentColor }
        return true
    }

    override func removePressedIndicator() -> Bool {
        fillColorGetter = { .colorWellSegmentColor }
        return true
    }

    override func performAction() -> Bool {
        guard let action = colorWell?.swatchSegment?.action(forStyle: .colorPanel) else {
            return false
        }
        return action()
    }

    override func mouseUp(with event: NSEvent) {
        // Dragging shouldn't prevent mouse up from working on this
        // segment, so set isDragging to false before calling super.
        draggingInformation.isDragging = false
        super.mouseUp(with: event)
    }
}

// MARK: Accessibility
extension ToggleSegment {
    override func accessibilityLabel() -> String? {
        "color picker"
    }
}
