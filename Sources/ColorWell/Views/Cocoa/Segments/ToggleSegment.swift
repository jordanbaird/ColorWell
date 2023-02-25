//
// ToggleSegment.swift
// ColorWell
//

import Cocoa

/// A segment that, when pressed, toggles the color panel.
internal class ToggleSegment: ColorWellSegment {
    /// Shared storage for the `cachedImage` property.
    private static let cachedImageStorage = Storage<ToggleSegment, NSImage>()

    /// The default width for a toggle segment.
    static let defaultWidth: CGFloat = 20

    /// A layer that contains an image indicating that the
    /// segment toggles the color panel.
    private var imageLayer: CALayer?

    /// An image that indicates that the segment toggles the
    /// color panel, cached for efficient retrieval.
    private var cachedImage: NSImage {
        // Force unwrap is okay here, as the image ships with Cocoa.
        Self.cachedImageStorage.value(
            forObject: self,
            default: NSImage(named: NSImage.touchBarColorPickerFillName)!.clippedToSquare()
        )
    }

    override var side: Side { .right }

    override init(colorWell: ColorWell) {
        super.init(colorWell: colorWell)
        // Constraining this segment's width will force
        // the other segment to fill the remaining space.
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: Self.defaultWidth).isActive = true
    }
}

// MARK: Instance Methods
extension ToggleSegment {
    /// Adds a layer that contains an image indicating that the
    /// segment toggles the color panel.
    private func updateImageLayer(_ dirtyRect: NSRect) {
        imageLayer?.removeFromSuperlayer()
        imageLayer = nil

        guard let layer else {
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

        var image = cachedImage

        if state == .highlight {
            image = NSApp.effectiveAppearanceIsDarkAppearance
            ? image.tinted(to: .white, amount: 0.33)
            : image.tinted(to: .black, amount: 0.2)
        }

        imageLayer.contents = image

        if !colorWellIsEnabled {
            imageLayer.opacity = 0.5
        }

        layer.addSublayer(imageLayer)

        self.imageLayer = imageLayer
    }
}

// MARK: Overrides
extension ToggleSegment {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateImageLayer(dirtyRect)
    }

    override func performAction() -> Bool {
        guard let colorWell else {
            return false
        }
        if colorWell.isActive {
            colorWell.deactivate()
            state = .default
        } else {
            colorWell.activateAutoVerifyingExclusive()
            state = .pressed
        }
        return true
    }
}

// MARK: Accessibility
extension ToggleSegment {
    override func accessibilityLabel() -> String? {
        "color picker"
    }
}