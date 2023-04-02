//
// DrawingStyle.swift
// ColorWell
//

import Cocoa

/// Constants that represent the drawing styles used by the
/// system to render colors and assets.
///
/// These values serve mainly to indicate whether a value of
/// the more complex `NSAppearance` type represents a light
/// or dark appearance. The drawing style that corresponds to
/// the currently active appearance can be retrieved through
/// the `DrawingStyle.current` static property.
enum DrawingStyle {
    /// A drawing style that indicates a dark appearance.
    case dark

    /// A drawing style that indicates a light appearance.
    case light

    // MARK: Static Properties

    /// The drawing style of the current appearance.
    static var current: Self {
        let currentAppearance: NSAppearance = {
            guard #available(macOS 11.0, *) else {
                return .current
            }
            return .currentDrawing()
        }()
        return currentAppearance.drawingStyle
    }

    // MARK: Initializers

    /// Creates a drawing style that corresponds to the specified appearance.
    init(appearance: NSAppearance) {
        enum LocalCache {
            static let systemDarkNames: Set<NSAppearance.Name> = {
                if #available(macOS 10.14, *) {
                    return [
                        .darkAqua,
                        .vibrantDark,
                        .accessibilityHighContrastDarkAqua,
                        .accessibilityHighContrastVibrantDark,
                    ]
                }
                return [.vibrantDark]
            }()
        }

        switch appearance.name {
        case let name where (
            LocalCache.systemDarkNames.contains(name) ||
            name.rawValue.lowercased().contains("dark")
        ):
            self = .dark
        default:
            self = .light
        }
    }
}
