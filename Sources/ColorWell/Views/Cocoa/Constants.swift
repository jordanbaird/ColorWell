//===----------------------------------------------------------------------===//
//
// Constants.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

// MARK: - Constants

/// A namespace for constants shared by all instances of ``ColorWell``.
internal enum Constants {
    /// A base value to use when computing the width of lines drawn as
    /// part of a color well or its elements.
    static let lineWidth: CGFloat = 1

    /// The default frame for a color well.
    static let defaultFrame = NSRect(x: 0, y: 0, width: 64, height: 28)

    /// The color shown by color wells that were not initialized with
    /// an initial value.
    ///
    /// Currently, this color is an RGBA white.
    static let defaultColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)

    /// The default style for a color well.
    static let defaultStyle = ColorWell.Style.expanded

    /// Hexadecimal strings used to construct the default colors shown
    /// in a color well's popover.
    static let defaultHexStrings = [
        "56C1FF", "72FDEA", "88FA4F", "FFF056", "FF968D", "FF95CA",
        "00A1FF", "15E6CF", "60D937", "FFDA31", "FF644E", "FF42A1",
        "0076BA", "00AC8E", "1FB100", "FEAE00", "ED220D", "D31876",
        "004D80", "006C65", "017101", "F27200", "B51800", "970E53",
        "FFFFFF", "D5D5D5", "929292", "5E5E5E", "000000",
    ]

    /// The default colors shown in a color well's popover.
    static let defaultSwatchColors = defaultHexStrings.compactMap { string in
        NSColor(hexString: string)
    }
}
