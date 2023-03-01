//
// ColorWellStyle.swift
// ColorWell
//

#if canImport(SwiftUI)

// MARK: - ColorWellStyle

/// A type that specifies the appearance and behavior of a color well.
public protocol ColorWellStyle {
    /// Values that configure a color well's style.
    typealias Configuration = _ColorWellStyleConfiguration

    /// Values that configure the color well's style.
    var configuration: Configuration { get }
}

// MARK: - Hidden Namespace

/// A namespace for the various color well style types.
///
/// This exists because Swift Package Manager's diagnostics were getting
/// confused. All types contained within are exposed globally via public
/// typealiases, so use those instead (i.e. use ``ExpandedColorWellStyle``
/// instead of `_ColorWellStyle.ExpandedStyle`).
public enum _ColorWellStyle { }

// MARK: - ExpandedColorWellStyle

extension _ColorWellStyle {
    /// A color well style that displays the color well's color alongside
    /// a dedicated button that toggles the system color panel.
    public struct ExpandedStyle: ColorWellStyle {
        public let configuration = Configuration(style: .expanded)

        /// Creates the ``ColorWellStyle/swatches`` color well style.
        public init() { }
    }
}

/// A color well style that displays the color well's color alongside
/// a dedicated button that toggles the system color panel.
public typealias ExpandedColorWellStyle = _ColorWellStyle.ExpandedStyle

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

extension _ColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and shows a popover containing the color well's
    /// swatch colors when clicked.
    public struct SwatchesStyle: ColorWellStyle {
        public let configuration = Configuration(style: .swatches)

        /// Creates the ``ColorWellStyle/swatches`` color well style.
        public init() { }
    }
}

/// A color well style that displays the color well's color inside of a
/// rectangular control, and shows a popover containing the color well's
/// swatch colors when clicked.
public typealias SwatchesColorWellStyle = _ColorWellStyle.SwatchesStyle

extension ColorWellStyle where Self == SwatchesColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and shows a popover containing the color well's
    /// swatch colors when clicked.
    public static var swatches: SwatchesColorWellStyle {
        SwatchesColorWellStyle()
    }
}

// MARK: - ColorPanelColorWellStyle

extension _ColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and toggles the system color panel when clicked.
    public struct ColorPanelStyle: ColorWellStyle {
        public let configuration = Configuration(style: .colorPanel)

        /// Creates the ``ColorWellStyle/colorPanel`` color well style.
        public init() { }
    }
}

/// A color well style that displays the color well's color inside of a
/// rectangular control, and toggles the system color panel when clicked.
public typealias ColorPanelColorWellStyle = _ColorWellStyle.ColorPanelStyle

extension ColorWellStyle where Self == ColorPanelColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and toggles the system color panel when clicked.
    public static var colorPanel: ColorPanelColorWellStyle {
        ColorPanelColorWellStyle()
    }
}
#endif
