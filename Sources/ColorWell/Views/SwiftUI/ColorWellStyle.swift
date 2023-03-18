//
// ColorWellStyle.swift
// ColorWell
//

#if canImport(SwiftUI)

// MARK: - ColorWellStyleConfiguration

/// Values that configure a color well's style.
public struct _ColorWellStyleConfiguration {
    /// The underlying style of the color well.
    var style: ColorWell.Style?
}

extension _ColorWellStyleConfiguration: CustomStringConvertible {
    public var description: String {
        style.map(String.init) ?? "nil"
    }
}

// MARK: - ColorWellStyle

/// A type that specifies the appearance and behavior of a color well.
public protocol ColorWellStyle {
    /// Values that configure the color well's style.
    var _configuration: _ColorWellStyleConfiguration { get }
}

// MARK: - ExpandedColorWellStyle

/// A color well style that displays the color well's color alongside
/// a dedicated button that toggles the system color panel.
///
/// Clicking inside the color area displays a popover containing the
/// color well's swatch colors.
///
/// You can also use ``expanded`` to construct this style.
public struct ExpandedColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .expanded)

    /// Creates an instance of the expanded color well style.
    public init() { }
}

extension ColorWellStyle where Self == ExpandedColorWellStyle {
    /// A color well style that displays the color well's color alongside
    /// a dedicated button that toggles the system color panel.
    ///
    /// Clicking inside the color area displays a popover containing the
    /// color well's swatch colors.
    public static var expanded: ExpandedColorWellStyle {
        ExpandedColorWellStyle()
    }
}

// MARK: - SwatchesColorWellStyle

/// A color well style that displays the color well's color inside of a
/// rectangular control, and shows a popover containing the color well's
/// swatch colors when clicked.
///
/// You can also use ``swatches`` to construct this style.
public struct SwatchesColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .swatches)

    /// Creates an instance of the swatches color well style.
    public init() { }
}

extension ColorWellStyle where Self == SwatchesColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and shows a popover containing the color well's
    /// swatch colors when clicked.
    public static var swatches: SwatchesColorWellStyle {
        SwatchesColorWellStyle()
    }
}

// MARK: - ColorPanelColorWellStyle

/// A color well style that displays the color well's color inside of a
/// rectangular control, and toggles the system color panel when clicked.
///
/// You can also use ``colorPanel`` to construct this style.
public struct PanelColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .colorPanel)

    /// Creates an instance of the color panel color well style.
    public init() { }
}

extension ColorWellStyle where Self == PanelColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and toggles the system color panel when clicked.
    public static var colorPanel: PanelColorWellStyle {
        PanelColorWellStyle()
    }
}
#endif
