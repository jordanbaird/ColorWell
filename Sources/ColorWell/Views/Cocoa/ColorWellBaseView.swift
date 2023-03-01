//
// ColorWellBaseView.swift
// ColorWell
//

import Cocoa

/// A base view class that contains some default functionality for use in
/// the main ``ColorWell`` class.
///
/// The public ``ColorWell`` class inherits from this class. The underscore
/// in front of its name indicates that this is a private API, and subject
/// to change. This class exists to enable public properties and methods to
/// be overridden without polluting the package's documentation.
public class _ColorWellBaseView: NSView {
    // TODO: Implement standin for `init(coder:)`
    // required convenience init?(_coder: NSCoder) {
    //     self.init(coder: _coder)
    // }
}

// MARK: Instance Properties
extension _ColorWellBaseView {
    /// A custom value for the color well's alignment rect insets.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal var customAlignmentRectInsets: NSEdgeInsets {
        super.alignmentRectInsets
    }

    /// A custom value for the color well's intrinsic content size.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal var customIntrinsicContentSize: NSSize {
        super.intrinsicContentSize
    }

    /// A custom value for the color well's accessibility children.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal var customAccessibilityChildren: [Any]? {
        super.accessibilityChildren()
    }

    /// A custom value that returns whether the color well is enabled,
    /// from an accessibility perspective.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal var customAccessibilityEnabled: Bool {
        super.isAccessibilityEnabled()
    }

    /// A custom value for the color well's accessibility value.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal var customAccessibilityValue: Any? {
        super.accessibilityValue()
    }

    /// A custom value for the color well's accessibility press action.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal var customAccessibilityPerformPress: () -> Bool {
        super.accessibilityPerformPress
    }
}

// MARK: Overrides
extension _ColorWellBaseView {
    public override var alignmentRectInsets: NSEdgeInsets {
        customAlignmentRectInsets
    }

    public override var intrinsicContentSize: NSSize {
        customIntrinsicContentSize
    }
}

// MARK: Accessibility
extension _ColorWellBaseView {

    // MARK: Custom Values

    public override func accessibilityChildren() -> [Any]? {
        customAccessibilityChildren
    }

    public override func isAccessibilityEnabled() -> Bool {
        customAccessibilityEnabled
    }

    public override func accessibilityValue() -> Any? {
        customAccessibilityValue
    }

    // MARK: Fixed Values

    public override func accessibilityRole() -> NSAccessibility.Role? {
        .colorWell
    }

    public override func isAccessibilityElement() -> Bool {
        true
    }

    // MARK: Custom Actions

    public override func accessibilityPerformPress() -> Bool {
        customAccessibilityPerformPress()
    }
}
