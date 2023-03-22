//
// ColorWellToggleSegment.swift
// ColorWell
//

import Cocoa

/// A segment that toggles the color panel when pressed.
class ColorWellToggleSegment: ColorWellSegment {

    // MARK: Static Properties

    static let widthConstant: CGFloat = 20

    // MARK: Instance Properties

    private var cachedImageLayer: CALayer?

    override var side: Side { .right }

    override var rawColor: NSColor {
        switch state {
        case .highlight:
            return .highlightedColorWellSegmentColor
        case .pressed:
            return .selectedColorWellSegmentColor
        default:
            return .colorWellSegmentColor
        }
    }

    // MARK: Initializers

    override init?(colorWell: ColorWell?) {
        super.init(colorWell: colorWell)
        // Constraining this segment's width will force the other
        // segment to fill the remaining space.
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: Self.widthConstant).isActive = true
    }
}

// MARK: Instance Methods
extension ColorWellToggleSegment {
    /// Adds a layer that contains an image indicating that the
    /// segment toggles the color panel.
    private func updateImageLayer(_ dirtyRect: NSRect) {
        enum Cache {
            private static let defaultImage: NSImage = {
                // Force unwrap is okay here, as the image is an AppKit builtin.
                let image = NSImage(named: NSImage.touchBarColorPickerFillName)!
                return image.clippedToSquare()
            }()

            static let defaultContents = {
                let scale = defaultImage.recommendedLayerContentsScale(0.0)
                return defaultImage.layerContents(forContentsScale: scale)
            }()

            static let enabledTintedForDarkAppearance = {
                let image = defaultImage.tinted(to: .white, amount: 0.33)
                let scale = image.recommendedLayerContentsScale(0.0)
                return image.layerContents(forContentsScale: scale)
            }()

            static let enabledTintedForLightAppearance = {
                let image = defaultImage.tinted(to: .black, amount: 0.20)
                let scale = image.recommendedLayerContentsScale(0.0)
                return image.layerContents(forContentsScale: scale)
            }()

            static let disabledTintedForDarkAppearance = {
                let image = NSImage(size: defaultImage.size, flipped: false) { bounds in
                    defaultImage
                        .tinted(to: .gray, amount: 0.33)
                        .draw(in: bounds, from: bounds, operation: .copy, fraction: 0.5)
                    return true
                }
                let scale = image.recommendedLayerContentsScale(0.0)
                return image.layerContents(forContentsScale: scale)
            }()

            static let disabledTintedForLightAppearance = {
                let image = NSImage(size: defaultImage.size, flipped: false) { bounds in
                    defaultImage
                        .tinted(to: .gray, amount: 0.20)
                        .draw(in: bounds, from: bounds, operation: .copy, fraction: 0.5)
                    return true
                }
                let scale = image.recommendedLayerContentsScale(0.0)
                return image.layerContents(forContentsScale: scale)
            }()

            static func tintedForDarkAppearance(_ isEnabled: Bool) -> Any {
                guard isEnabled else {
                    return disabledTintedForDarkAppearance
                }
                return enabledTintedForDarkAppearance
            }

            static func tintedForLightAppearance(_ isEnabled: Bool) -> Any {
                guard isEnabled else {
                    return disabledTintedForLightAppearance
                }
                return enabledTintedForLightAppearance
            }
        }

        cachedImageLayer?.removeFromSuperlayer()
        cachedImageLayer = nil

        guard let layer else {
            return
        }

        let dimension = min(dirtyRect.width, dirtyRect.height) - 6
        let imageLayer = CALayer()

        imageLayer.frame = NSRect(
            x: 0,
            y: 0,
            width: dimension,
            height: dimension
        ).centered(in: dirtyRect)

        if state == .highlight || !isEnabled {
            if effectiveAppearance.isDarkAppearance {
                imageLayer.contents = Cache.tintedForDarkAppearance(isEnabled)
            } else {
                imageLayer.contents = Cache.tintedForLightAppearance(isEnabled)
            }
        } else {
            imageLayer.contents = Cache.defaultContents
        }

        layer.addSublayer(imageLayer)
        cachedImageLayer = imageLayer
    }
}

// MARK: Perform Action
extension ColorWellToggleSegment {
    override class func performAction(for segment: ColorWellSegment) -> Bool {
        guard let colorWell = segment.colorWell else {
            return false
        }
        if colorWell.isActive {
            colorWell.deactivate()
        } else {
            colorWell.activateAutoVerifyingExclusive()
        }
        return true
    }
}

// MARK: Overrides
extension ColorWellToggleSegment {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateImageLayer(dirtyRect)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard isEnabled else {
            return
        }

        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else if isActive {
            state = .pressed
        } else {
            state = .default
        }
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .highlight, .pressed, .default:
            return true
        case .hover:
            return false
        }
    }
}

// MARK: Accessibility
extension ColorWellToggleSegment {
    override func accessibilityLabel() -> String? {
        "color picker"
    }
}
