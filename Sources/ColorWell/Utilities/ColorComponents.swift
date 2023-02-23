//
// ColorComponents.swift
// ColorWell
//

import Cocoa

/// A type that contains information about the color components for a color.
internal enum ColorComponents {
    case rgb(red: Double, green: Double, blue: Double, alpha: Double)
    case cmyk(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double)
    case grayscale(white: Double, alpha: Double)
    case catalog(name: String)
    case unknown(color: NSColor)
    case deviceN
    case indexed
    case lab
    case pattern
}

// MARK: Properties
extension ColorComponents {
    /// The name of the color space associated with this instance.
    var colorSpaceName: String {
        switch self {
        case .rgb:
            return "rgb"
        case .cmyk:
            return "cmyk"
        case .grayscale:
            return "grayscale"
        case .catalog:
            return "catalog color"
        case .unknown:
            return "unknown color space"
        case .deviceN:
            return "deviceN"
        case .indexed:
            return "indexed"
        case .lab:
            return "L*a*b*"
        case .pattern:
            return "pattern image"
        }
    }

    /// The raw components extracted from this instance.
    var extractedComponents: [Any] {
        switch self {
        case .rgb(let red, let green, let blue, let alpha):
            return [red, green, blue, alpha]
        case .cmyk(let cyan, let magenta, let yellow, let black, let alpha):
            return [cyan, magenta, yellow, black, alpha]
        case .grayscale(let white, let alpha):
            return [white, alpha]
        case .catalog(let name):
            return [name]
        case .unknown(let color):
            guard color.type == .componentBased else {
                return ["\(color)"]
            }

            var components = [CGFloat](repeating: 0, count: color.numberOfComponents)
            color.getComponents(&components)

            return components.map { component in
                Double(component)
            }
        default:
            return []
        }
    }

    /// String representations of the raw components extracted from this instance.
    var extractedComponentStrings: [String] {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6

        return extractedComponents.compactMap { component in
            if let component = component as? Double {
                return formatter.string(for: component)
            }
            return String(describing: component)
        }
    }
}

// MARK: Initializers
extension ColorComponents {
    /// Creates color components from the specified color.
    init(color: NSColor) {
        switch color.type {
        case .componentBased:
            switch color.colorSpace.colorSpaceModel {
            case .rgb:
                self = .rgb(
                    red: color.redComponent,
                    green: color.greenComponent,
                    blue: color.blueComponent,
                    alpha: color.alphaComponent
                )
            case .cmyk:
                self = .cmyk(
                    cyan: color.cyanComponent,
                    magenta: color.magentaComponent,
                    yellow: color.yellowComponent,
                    black: color.blackComponent,
                    alpha: color.alphaComponent
                )
            case .gray:
                self = .grayscale(
                    white: color.whiteComponent,
                    alpha: color.alphaComponent
                )
            case .deviceN:
                self = .deviceN
            case .indexed:
                self = .indexed
            case .lab:
                self = .lab
            case .patterned:
                self = .pattern
            case .unknown:
                self = .unknown(color: color)
            @unknown default:
                self = .unknown(color: color)
            }
        case .pattern:
            self = .pattern
        case .catalog:
            self = .catalog(name: color.localizedColorNameComponent)
        @unknown default:
            self = .unknown(color: color)
        }
    }
}

// MARK: CustomStringConvertible
extension ColorComponents: CustomStringConvertible {
    var description: String {
        ([colorSpaceName] + extractedComponentStrings).joined(separator: " ")
    }
}
