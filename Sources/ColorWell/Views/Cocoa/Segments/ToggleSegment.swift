//
// ToggleSegment.swift
// ColorWell
//

import Cocoa

internal class ToggleSegment: ColorWellSegment {
    private var imageLayer: CALayer?

    override var side: Side { .right }

    override init(colorWell: ColorWell) {
        super.init(colorWell: colorWell)
        // Constraining this segment's width will force
        // the other segment to fill the remaining space.
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

// MARK: Instance Methods
extension ToggleSegment {
    /// Adds a layer that contains an image indicating that the
    /// segment opens the color panel.
    private func setImageLayer(clip: Bool = false) {
        imageLayer?.removeFromSuperlayer()
        imageLayer = nil

        guard let layer else {
            return
        }

        // Force unwrap is okay here, as the image ships with Cocoa.
        var image = NSImage(named: NSImage.touchBarColorPickerFillName)!

        if state == .highlight {
            image = NSApp.effectiveAppearanceIsDarkAppearance
            ? image.tinted(to: .white, amount: 0.33)
            : image.tinted(to: .black, amount: 0.2)
        }

        let dimension = min(layer.bounds.width, layer.bounds.height) - 5.5
        let imageLayer = CALayer()

        imageLayer.frame = NSRect(
            x: 0,
            y: 0,
            width: dimension,
            height: dimension
        ).centered(in: layer.bounds)

        imageLayer.contents = clip ? image.clippedToCircle() : image

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
        setImageLayer(clip: true)
    }

    override func performAction() {
        guard let colorWell else {
            return
        }
        if colorWell.isActive {
            colorWell.deactivate()
            state = .default
        } else {
            colorWell.activateAutoVerifyingExclusive()
            state = .pressed
        }
    }
}

// MARK: Accessibility
extension ToggleSegment {
    override func accessibilityLabel() -> String? {
        "color picker"
    }
}
