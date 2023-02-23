//
// Deprecated.swift
// ColorWell
//

import Cocoa

extension ColorWell {
    /// A Boolean value that indicates whether the color well's color panel
    /// allows adjusting the selected color's opacity.
    @available(*, deprecated, renamed: "showsAlpha")
    @objc dynamic
    public var supportsOpacity: Bool {
        get { showsAlpha }
        set { showsAlpha = newValue }
    }

    /// Activates the color well and displays its color panel.
    ///
    /// Both elements will remain synchronized until either the color panel
    /// is closed, or the color well is deactivated.
    ///
    /// - Parameter exclusive: If this value is `true`, all other active
    ///   color wells attached to this color well's color panel will be
    ///   deactivated.
    @available(*, deprecated, renamed: "activate(exclusive:)")
    public func activate(_ exclusive: Bool) {
        activate(exclusive: exclusive)
    }

    /// Adds an action to perform when the color well's color changes.
    ///
    /// ```swift
    /// let colorWell = ColorWell()
    /// let textView = NSTextView()
    /// // ...
    /// // ...
    /// // ...
    /// colorWell.observeColor { color in
    ///     textView.textColor = color
    /// }
    /// ```
    ///
    /// - Parameter handler: A block of code that will be executed when
    ///   the color well's color changes.
    @available(*, deprecated, renamed: "onColorChange(perform:)")
    public func observeColor(onChange handler: @escaping (NSColor) -> Void) {
        onColorChange(perform: handler)
    }
}
