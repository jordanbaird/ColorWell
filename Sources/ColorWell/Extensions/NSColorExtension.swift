//===----------------------------------------------------------------------===//
//
// NSColorExtension.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

extension NSColor {
  /// The module-defined color for buttons and other, similar controls.
  static var buttonColor: NSColor {
    .init(named: "ButtonColor", bundle: .module)!
  }
  
  /// The current color object, using the `sRGB` color space.
  var sRGB: NSColor {
    usingColorSpace(.sRGB)!
  }
  
  /// The `sRGB` color space components of the current color object.
  var sRGBComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    let color = sRGB
    let r = color.redComponent
    let g = color.greenComponent
    let b = color.blueComponent
    let a = color.alphaComponent
    return (r, g, b, a)
  }
  
  /// Returns the average of this color's red, green, and blue
  /// components, approximating the brightness of the color.
  var averageBrightness: CGFloat {
    let c = sRGBComponents
    return (c.red + c.green + c.blue) / 3
  }
  
  /// Creates a color from a hexadecimal string.
  convenience init?(hexString: String) {
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
  
  /// Returns a basic description of the color, alongside
  /// the components for the color's current color space.
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
  
  /// Creates a value containing a description of the color, for
  /// use with accessibility features.
  func createAccessibilityValue() -> String {
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
}
