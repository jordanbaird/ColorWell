//
// ColorWellToggleSegment.swift
// ColorWell
//

import Cocoa

// MARK: - ColorWellToggleSegment

/// A segment that toggles the color panel when pressed.
class ColorWellToggleSegment: ColorWellSegment {

    // MARK: Static Properties

    static let widthConstant: CGFloat = 20

    // MARK: Instance Properties

    private let cachedImageLayer = Cache(CALayer(), id: ImageLayerCacheID())

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

        cachedImageLayer.updateConstructor { id in
            enum LocalCache {
                private static let defaultImage: NSImage = {
                    // Force unwrap is okay here, as the image is an AppKit builtin.
                    // swiftlint:disable:next force_unwrapping
                    let image = NSImage(named: NSImage.touchBarColorPickerFillName)!
                    return image.clippedToSquare()
                }()

                private static let enabledTintedForDarkAppearance: Any = {
                    let image = defaultImage.tinted(to: .white, amount: 0.33)
                    let scale = image.recommendedLayerContentsScale(0.0)
                    return image.layerContents(forContentsScale: scale)
                }()

                private static let enabledTintedForLightAppearance: Any = {
                    let image = defaultImage.tinted(to: .black, amount: 0.20)
                    let scale = image.recommendedLayerContentsScale(0.0)
                    return image.layerContents(forContentsScale: scale)
                }()

                private static let disabledTintedForDarkAppearance: Any = {
                    let image = NSImage(size: defaultImage.size, flipped: false) { bounds in
                        defaultImage
                            .tinted(to: .gray, amount: 0.33)
                            .draw(in: bounds, from: bounds, operation: .copy, fraction: 0.5)
                        return true
                    }
                    let scale = image.recommendedLayerContentsScale(0.0)
                    return image.layerContents(forContentsScale: scale)
                }()

                private static let disabledTintedForLightAppearance: Any = {
                    let image = NSImage(size: defaultImage.size, flipped: false) { bounds in
                        defaultImage
                            .tinted(to: .gray, amount: 0.20)
                            .draw(in: bounds, from: bounds, operation: .copy, fraction: 0.5)
                        return true
                    }
                    let scale = image.recommendedLayerContentsScale(0.0)
                    return image.layerContents(forContentsScale: scale)
                }()

                static let defaultContents: Any = {
                    let scale = defaultImage.recommendedLayerContentsScale(0.0)
                    return defaultImage.layerContents(forContentsScale: scale)
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

            let dimension = min(id.dirtyRect.width, id.dirtyRect.height) - 6
            let imageLayer = CALayer()

            imageLayer.frame = NSRect(
                x: 0,
                y: 0,
                width: dimension,
                height: dimension
            ).centered(in: id.dirtyRect)

            if id.state == .highlight || !id.isEnabled {
                switch DrawingStyle.current {
                case .dark:
                    imageLayer.contents = LocalCache.tintedForDarkAppearance(id.isEnabled)
                case .light:
                    imageLayer.contents = LocalCache.tintedForLightAppearance(id.isEnabled)
                }
            } else {
                imageLayer.contents = LocalCache.defaultContents
            }

            return imageLayer
        }
    }
}

// MARK: Instance Methods
extension ColorWellToggleSegment {
    /// Adds a layer that contains an image indicating that the
    /// segment toggles the color panel.
    private func updateImageLayer(_ dirtyRect: NSRect) {
        cachedImageLayer.cachedValue.removeFromSuperlayer()
        guard let layer else {
            return
        }
        cachedImageLayer.recache(id: ImageLayerCacheID(dirtyRect, segment: self))
        layer.addSublayer(cachedImageLayer.cachedValue)
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

// MARK: - ColorWellToggleSegment ImageLayerCacheID

extension ColorWellToggleSegment {
    private struct ImageLayerCacheID: Equatable {
        let dirtyRect: NSRect
        let state: State
        let isEnabled: Bool

        init() {
            self.dirtyRect = .zero
            self.state = .default
            self.isEnabled = true
        }

        init(_ dirtyRect: NSRect, segment: ColorWellToggleSegment) {
            self.dirtyRect = dirtyRect
            self.state = segment.state
            self.isEnabled = segment.isEnabled
        }
    }
}
