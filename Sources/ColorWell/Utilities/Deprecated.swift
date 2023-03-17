//
// Deprecated.swift
// ColorWell
//

import Cocoa

extension ColorWell {
    /// The color panel associated with the color well.
    @available(*, deprecated, message: "'colorPanel' is no longer used and will be removed in a future release. Use 'NSColorPanel.shared' instead.")
    public var colorPanel: NSColorPanel { .shared }
}
