//===----------------------------------------------------------------------===//
//
// ColorWellBaseView.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

// FIXME: Remove this when @_documentation(visibility:) becomes official.
//
/// A base view class that contains some default functionality for use in
/// the main ``ColorWell`` class.
///
/// The public ``ColorWell`` class inherits from this class. The underscore
/// in front of its name indicates that this is a private API, and subject
/// to change. This class exists to enable public properties and methods to
/// be overridden without polluting the package's documentation.
public class _ColorWellBaseView: NSView { }

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
}

// MARK: Instance Methods
extension _ColorWellBaseView {
    /// Returns a value for the given accessibility attribute.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal func provideValue(forAttribute attribute: NSAccessibility.Attribute) -> Any? { nil }

    /// Performs code for the given accessibility action.
    ///
    /// To be overridden by the main ``ColorWell`` class.
    @objc dynamic
    internal func performAction(forType type: NSAccessibility.Action) -> Bool { false }

    /// Returns a value for the given accessibility attribute, performing
    /// dynamic casting to type `T`, based on the context of the callee.
    ///
    /// ** Non-overrideable **
    private final func provideValue<T>(forAttribute attribute: NSAccessibility.Attribute) -> T? {
        provideValue(forAttribute: attribute) as? T
    }
}

// MARK: Overrides
extension _ColorWellBaseView {
    //@_documentation(visibility: internal)
    public override var alignmentRectInsets: NSEdgeInsets {
        customAlignmentRectInsets
    }

    //@_documentation(visibility: internal)
    public override var intrinsicContentSize: NSSize {
        customIntrinsicContentSize
    }
}

// MARK: Accessibility
extension _ColorWellBaseView {
    //@_documentation(visibility: internal)
    public override func accessibilityChildren() -> [Any]? {
        provideValue(forAttribute: .children)
    }

    //@_documentation(visibility: internal)
    public override func accessibilityPerformPress() -> Bool {
        performAction(forType: .press)
    }

    //@_documentation(visibility: internal)
    public override func accessibilityRole() -> NSAccessibility.Role? {
        .colorWell
    }

    //@_documentation(visibility: internal)
    public override func accessibilityValue() -> Any? {
        provideValue(forAttribute: .value)
    }

    //@_documentation(visibility: internal)
    public override func isAccessibilityElement() -> Bool {
        true
    }

    //@_documentation(visibility: internal)
    public override func isAccessibilityEnabled() -> Bool {
        provideValue(forAttribute: .enabled) ?? true
    }
}
