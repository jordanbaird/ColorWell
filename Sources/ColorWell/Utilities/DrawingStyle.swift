//
// DrawingStyle.swift
// ColorWell
//

import Cocoa

/// Constants that represent the drawing styles used
/// to render a view's appearance.
enum DrawingStyle {
    /// A drawing style that indicates a dark appearance.
    case dark

    /// A drawing style that indicates a light appearance.
    case light

    // MARK: Static Properties

    /// The drawing style of the appearance that the system uses
    /// for color and asset resolution, and that is active for
    /// drawing, usually from locking focus on a view.
    static var current: Self {
        if #available(macOS 11.0, *) {
            return Self(appearance: .currentDrawing())
        } else {
            return Self(appearance: .current)
        }
    }

    // MARK: Initializers

    /// Creates a drawing style from the specified appearance.
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
