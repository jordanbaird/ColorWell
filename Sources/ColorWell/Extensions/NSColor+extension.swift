//===----------------------------------------------------------------------===//
//
// NSColor+extension.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSColor {
  /// The module-defined color for buttons and other, similar controls.
  internal static var buttonColor: NSColor {
    .init(named: "ButtonColor", bundle: .module)!
  }

  /// The current color, using the `sRGB` color space.
  internal var sRGB: NSColor {
    usingColorSpace(.sRGB)!
  }

  /// The `sRGB` color space components of the current color.
  internal var sRGBComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    let color = sRGB
    let r = color.redComponent
    let g = color.greenComponent
    let b = color.blueComponent
    let a = color.alphaComponent
    return (r, g, b, a)
  }

  /// Returns the average of this color's red, green, and blue components,
  /// approximating the brightness of the color.
  internal var averageBrightness: CGFloat {
    let c = sRGBComponents
    return (c.red + c.green + c.blue) / 3
  }

  /// Creates a color from a hexadecimal string.
  internal convenience init?(hexString: String) {
    let hexString = hexString.trimmingCharacters(in: .init(["#"]))

    guard hexString.count % 2 == 0 else {
      return nil
    }

    let hexArray = hexString.map { "\($0)" }

    let rString = hexArray[0..<2].joined()
    let gString = hexArray[2..<4].joined()
    let bString = hexArray[4..<6].joined()
    let aString = {
      if hexArray.count == 6 {
        return "ff"
      } else {
        return hexArray[6..<8].joined()
      }
    }()

    let rInt = Int(rString, radix: 16)!
    let gInt = Int(gString, radix: 16)!
    let bInt = Int(bString, radix: 16)!
    let aInt = Int(aString, radix: 16)!

    let rFloat = CGFloat(rInt) / 255
    let gFloat = CGFloat(gInt) / 255
    let bFloat = CGFloat(bInt) / 255
    let aFloat = CGFloat(aInt) / 255

    self.init(srgbRed: rFloat, green: gFloat, blue: bFloat, alpha: aFloat)
  }

  /// Returns a basic description of the color, alongside the components for
  /// the color's current color space.
  private func extractSimpleDescriptionAndComponents() -> (description: String, components: [Double]) {
    switch colorSpace.colorSpaceModel {
    case .rgb: return (
      "rgb",
      [
        redComponent,
        greenComponent,
        blueComponent,
        alphaComponent,
      ])
    case .cmyk: return (
      "cmyk",
      [
        cyanComponent,
        magentaComponent,
        yellowComponent,
        blackComponent,
        alphaComponent,
      ])
    case .deviceN: return ("deviceN", [])
    case .gray: return (
      "grayscale",
      [
        whiteComponent,
        alphaComponent,
      ])
    case .indexed: return ("indexed", [])
    case .lab: return ("L*a*b*", [])
    case .patterned: return ("pattern", [])
    case .unknown: break
    @unknown default: break
    }
    return ("\(self)", [])
  }

  /// Creates a value containing a description of the color, for use with
  /// accessibility features.
  internal func createAccessibilityValue() -> String {
    switch type {
    case .componentBased:
      let extracted = extractSimpleDescriptionAndComponents()

      guard
        !extracted.components.isEmpty,
        extracted.components.count == numberOfComponents
      else {
        // Returning a generic description is the best we can do.
        // Example: "rgb color"
        return "\(extracted.description) color"
      }

      let results = [extracted.description] + extracted.components.map {
        var string = String($0)
        while
          string.count > 1,
          string.count > 8 || string.last == "0" || string.last == "."
        {
          string.removeLast()
        }
        assert(!string.isEmpty, "String should not be empty.")
        return string
      }

      return results.joined(separator: " ")
    case .catalog:
      return "catalog color \(localizedColorNameComponent)"
    case .pattern:
      return "pattern"
    @unknown default:
      break
    }
    return "\(self)"
  }

  /// Returns a Boolean value that indicates whether this color resembles another
  /// color, checking in the given color space with the given tolerance.
  ///
  /// - Note: If one or both colors cannot be converted to `colorSpace`, this method
  ///   returns `false`.
  ///
  /// - Parameters:
  ///   - other: A color to compare this color to.
  ///   - colorSpace: A color space to convert both colors to before running the check.
  ///   - tolerance: A threshold value that alters how strict the comparison is.
  ///
  /// - Returns: `true` if this color is "close enough" to `other`. False otherwise.
  internal func resembles(_ other: NSColor, using colorSpace: NSColorSpace, tolerance: CGFloat) -> Bool {
    guard
      let first = usingColorSpace(colorSpace),
      let second = other.usingColorSpace(colorSpace)
    else {
      return false
    }

    if first == second {
      return true
    }

    guard first.numberOfComponents == second.numberOfComponents else {
      return false
    }

    // Initialize `components1` to repeat 1 instead of 0. Otherwise, we
    // might end up with a false positive `true` result, if copying the
    // components fails.
    var components1 = [CGFloat](repeating: 1, count: first.numberOfComponents)
    var components2 = [CGFloat](repeating: 0, count: second.numberOfComponents)

    first.getComponents(&components1)
    second.getComponents(&components2)

    return (0..<components1.count).allSatisfy {
      abs(components1[$0] - components2[$0]) <= tolerance
    }
  }

  /// Returns a Boolean value that indicates whether this color resembles another
  /// color, with the given tolerance.
  ///
  /// This method checks all typical color spaces.
  ///
  /// - Parameters:
  ///   - other: A color to compare this color to.
  ///   - tolerance: A threshold value that alters how strict the comparison is.
  ///
  /// - Returns: `true` if this color is "close enough" to `other`. False otherwise.
  internal func resembles(_ other: NSColor, tolerance: CGFloat = 0.0001) -> Bool {
    if self == other {
      return true
    }

    let standardColorSpaces: [NSColorSpace] = [
      .sRGB,
      .extendedSRGB,
      .adobeRGB1998,
      .displayP3,
    ]

    for colorSpace in standardColorSpaces where resembles(other, using: colorSpace, tolerance: tolerance) {
      return true
    }

    let genericColorSpaces: [NSColorSpace] = [
      .genericRGB,
      .genericCMYK,
      .genericGray,
      .genericGamma22Gray,
      .extendedGenericGamma22Gray,
    ]

    for colorSpace in genericColorSpaces where resembles(other, using: colorSpace, tolerance: tolerance) {
      return true
    }

    let deviceColorSpaces: [NSColorSpace] = [
      .deviceRGB,
      .deviceCMYK,
      .deviceGray,
    ]

    for colorSpace in deviceColorSpaces where resembles(other, using: colorSpace, tolerance: tolerance) {
      return true
    }
    
    return false
  }
}
