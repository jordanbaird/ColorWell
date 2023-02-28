//
// ColorWellStyle.swift
// ColorWell
//

#if canImport(SwiftUI)

// MARK: - ColorWellStyle

/// A type that specifies the appearance and behavior of a color well.
public protocol ColorWellStyle {
    /// Values that configure a color well's style.
    typealias Configuration = ColorWellStyleConfiguration

    /// Values that configure the color well's style.
    var configuration: Configuration { get }
}

// MARK: - ExpandedColorWellStyle

/// A color well style that displays the color well's color alongside
/// a dedicated button that toggles the system color panel.
public struct ExpandedColorWellStyle: ColorWellStyle {
    public var configuration: Configuration {
        Configuration(style: .expanded)
    }

    /// Creates the ``expanded`` color well style.
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
public struct SwatchesColorWellStyle: ColorWellStyle {
    public var configuration: Configuration {
        Configuration(style: .swatches)
    }

    /// Creates the ``swatches`` color well style.
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
public struct ColorPanelColorWellStyle: ColorWellStyle {
    public var configuration: Configuration {
        Configuration(style: .colorPanel)
    }

    /// Creates the ``colorPanel`` color well style.
    public init() { }
}

extension ColorWellStyle where Self == ColorPanelColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and toggles the system color panel when clicked.
    public static var colorPanel: ColorPanelColorWellStyle {
        ColorPanelColorWellStyle()
    }
}
#endif
