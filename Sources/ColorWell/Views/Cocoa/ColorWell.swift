//===----------------------------------------------------------------------===//
//
// ColorWell.swift
//
//===----------------------------------------------------------------------===//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI
#endif

/// A view that displays a user-settable color value.
///
/// Color wells enable the user to select custom colors from within an app's
/// interface. A graphics app might, for example, include a color well to let
/// someone choose the fill color for a shape. Color wells display the currently
/// selected color, and interactions with the color well display interfaces
/// for selecting new colors.
public class ColorWell: _ColorWellBaseView {

    /// A base value to use when computing the width of lines drawn as
    /// part of a color well or its elements.
    internal static let lineWidth: CGFloat = 1

    /// The default frame for a color well.
    internal static let defaultFrame = NSRect(x: 0, y: 0, width: 64, height: 28)

    /// The color shown by color wells that were not initialized with
    /// an initial value.
    ///
    /// Currently, this color is an RGBA white.
    internal static let defaultColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)

    /// The default style for a color well.
    internal static let defaultStyle = ColorWell.Style.expanded

    /// Hexadecimal strings used to construct the default colors shown
    /// in a color well's popover.
    internal static let defaultHexStrings = [
        "56C1FF", "72FDEA", "88FA4F", "FFF056", "FF968D", "FF95CA",
        "00A1FF", "15E6CF", "60D937", "FFDA31", "FF644E", "FF42A1",
        "0076BA", "00AC8E", "1FB100", "FEAE00", "ED220D", "D31876",
        "004D80", "006C65", "017101", "F27200", "B51800", "970E53",
        "FFFFFF", "D5D5D5", "929292", "5E5E5E", "000000",
    ]

    /// The default colors shown in a color well's popover.
    internal static let defaultSwatchColors = defaultHexStrings.compactMap { string in
        NSColor(hexString: string)
    }

    // MARK: Private Properties

    /// A view that displays the color well's segments, side by side.
    private var layoutView: ColorWellLayoutView!

    /// The observations associated with the color well.
    private var observations = [ObjectIdentifier: Set<NSKeyValueObservation>]()

    /// A Boolean value that indicates whether the color well can
    /// currently perform synchronization with its color panel.
    private var canSynchronizeColorPanel = false

    /// A Boolean value that indicates whether the color well can
    /// currently execute its change handlers.
    private var canExecuteChangeHandlers = false

    /// A Boolean value that indicates whether the `showsAlpha` value
    /// should be synchronized the next time `synchronizeColorPanel()`
    /// is called.
    private var shouldSynchronizeShowsAlpha = false

    // FIXME: Only `NSColorPanel.shared` should be allowed as a value here.
    //
    /// The backing value for the public `colorPanel` property.
    ///
    /// Even though `NSColorPanel` is _supposed_ to be a singleton, it
    /// lets you create custom instances using initializers inherited
    /// from `NSObject`, `NSPanel`, etc. The problem is that `NSColorPanel`
    /// internally manages its memory, and caches parts of its interface.
    /// Color panels other than `NSColorPanel.shared` could get released,
    /// leaving behind a slew of cached objects with no reference of what
    /// they belong to.
    ///
    /// For now, we'll deprecate the public property's setter, but it
    /// should eventually be made into a get-only property, a la:
    ///
    /// ```
    /// public var colorPanel: NSColorPanel { .shared }
    /// ```
    private lazy var _colorPanel = NSColorPanel.shared {
        willSet {
            if isActive {
                newValue.activeColorWells.insert(self)
            }
        }
        didSet {
            removeColorPanelObservations()
            if isActive {
                oldValue.activeColorWells.remove(self)
                synchronizeColorPanel()
                setUpColorPanelObservations()
            }
        }
    }

    /// The backing value for the public `isActive` property.
    ///
    /// This enables key-value observation on the public property, while
    /// still allowing it to be get-only.
    private var _isActive = false {
        willSet {
            willChangeValue(for: \.isActive)
        }
        didSet {
            didChangeValue(for: \.isActive)
        }
    }

    /// The backing value for the public `showsAlpha` property.
    ///
    /// If the color well is active when this property is set, the color
    /// well's color panel's `showsAlpha` property is set to this value
    /// in a call to `synchronizeColorPanel()`. If the color well is not
    /// active when this property is set, the next call to `synchronizeColorPanel()`
    /// will set its color panel's `showsAlpha` to this value.
    private lazy var _showsAlpha = colorPanel.showsAlpha {
        didSet {
            shouldSynchronizeShowsAlpha = true
            if isActive {
                synchronizeColorPanel()
            }
        }
    }

    // MARK: Internal Properties

    /// The color well's change handlers.
    internal var changeHandlers = [IdentifiableAction<NSColor>]()

    /// The popover context associated with the color well.
    internal var popoverContext: ColorWellPopoverContext?

    /// The segment that shows the color well's color.
    internal var swatchSegment: SwatchSegment {
        layoutView.swatchSegment
    }

    /// The segment that toggles the color well's color panel.
    internal var toggleSegment: ToggleSegment {
        layoutView.toggleSegment
    }

    // MARK: Public Properties

    /// A Boolean value that indicates whether the color well supports being
    /// included in group selections.
    ///
    /// The user can select multiple color wells by holding "Shift" while
    /// selecting.
    ///
    /// Default value is `true`.
    @objc dynamic
    public var allowsMultipleSelection = true

    /// The colors that will be shown as swatches in the color well's popover.
    ///
    /// The default values are defined according to the following hexadecimal
    /// codes:
    /// ```swift
    /// [
    ///     "56C1FF", "72FDEA", "88FA4F", "FFF056", "FF968D", "FF95CA",
    ///     "00A1FF", "15E6CF", "60D937", "FFDA31", "FF644E", "FF42A1",
    ///     "0076BA", "00AC8E", "1FB100", "FEAE00", "ED220D", "D31876",
    ///     "004D80", "006C65", "017101", "F27200", "B51800", "970E53",
    ///     "FFFFFF", "D5D5D5", "929292", "5E5E5E", "000000"
    /// ]
    /// ```
    /// ![Default swatches](grid-view)
    ///
    /// You can add and remove values to change the swatches that are displayed.
    ///
    /// ```swift
    /// let colorWell = ColorWell()
    /// colorWell.swatchColors += [
    ///     .systemPurple,
    ///     .controlColor,
    ///     .windowBackgroundColor
    /// ]
    /// colorWell.swatchColors.removeFirst()
    /// ```
    ///
    /// Whatever value this property holds at the time the user opens the color
    /// well's popover is the value that will be used to construct its swatches.
    /// Each popover is constructed lazily, so if this value changes between
    /// popover sessions, the next popover that is displayed will reflect the
    /// changes.
    ///
    /// - Note: If the array is empty, the color well's ``colorPanel`` will be
    ///   shown instead of a popover.
    @objc dynamic
    public var swatchColors = defaultSwatchColors

    /// The color well's color.
    ///
    /// Setting this value immediately updates the visual state of both
    /// the color well and its color panel, and executes all change
    /// handlers stored by the color well.
    @objc dynamic
    public var color: NSColor {
        didSet {
            if isActive {
                synchronizeColorPanel()
            }
            if swatchSegment.fillColor != color {
                swatchSegment.fillColor = color
            }
            executeChangeHandlers()
        }
    }

    /// The color panel controlled by the color well.
    ///
    /// - Important: The setter for this property is deprecated, and will be
    ///   removed in a future release. Using any other value besides `NSColorPanel.shared`
    ///   will result in memory leaks.
    @objc dynamic
    public var colorPanel: NSColorPanel {
        get {
            _colorPanel
        }
        // Ideally, this would go in Deprecated.swift, but there isn't a way to make
        // separate getter and setter declarations.
        @available(*, deprecated, message: "Only the 'shared' instance of NSColorPanel is valid. Creation of additional instances causes memory leaks.")
        set {
            _colorPanel = newValue
        }
    }

    /// A Boolean value that indicates whether the color well is
    /// currently active.
    ///
    /// You can change this value using the ``activate(exclusive:)``
    /// and ``deactivate()`` methods.
    @objc dynamic
    public var isActive: Bool { _isActive }

    /// A Boolean value that indicates whether the color well is enabled.
    ///
    /// If `false`, the color well will not react to mouse events, open
    /// its color panel, or show its popover.
    ///
    /// Default value is `true`.
    @objc dynamic
    public var isEnabled: Bool = true {
        didSet {
            updateActiveState()
            needsDisplay = true
        }
    }

    /// A Boolean value indicating whether the color well's color panel
    /// shows alpha values and an opacity slider.
    @objc dynamic
    public var showsAlpha: Bool {
        get { _showsAlpha }
        set { _showsAlpha = newValue }
    }

    /// The appearance and behavior style to apply to the color well.
    ///
    /// The value of this property determines how the color well is
    /// displayed, and specifies how it should respond when the user
    /// interacts with it. For details, see ``Style-swift.enum``.
    @objc dynamic
    public var style: Style {
        didSet {
            needsDisplay = true
        }
    }

    // MARK: Initializers

    /// Creates a color well with the given frame, color, and style.
    ///
    /// - Parameters:
    ///   - frameRect: The frame rectangle for the created color panel.
    ///   - color: The initial value of the color well's color.
    ///   - style: The style to use to display the color well.
    public init(frame frameRect: NSRect, color: NSColor, style: Style) {
        self.color = color
        self.style = style
        super.init(frame: frameRect)
        sharedInit()
    }

    /// Creates a color well with the given frame and color.
    ///
    /// - Parameters:
    ///   - frameRect: The frame rectangle for the created color panel.
    ///   - color: The initial value of the color well's color.
    public convenience init(frame frameRect: NSRect, color: NSColor) {
        self.init(frame: frameRect, color: color, style: Self.defaultStyle)
    }

    /// Creates a color well with the given frame.
    ///
    /// - Parameter frameRect: The frame rectangle for the created color panel.
    public override convenience init(frame frameRect: NSRect) {
        self.init(frame: frameRect, color: Self.defaultColor)
    }

    /// Creates a color well with the default frame, color, and style.
    public convenience init() {
        self.init(frame: Self.defaultFrame)
    }

    /// Creates a color well with the given style.
    ///
    /// - Parameter style: The style to use to display the color well.
    public convenience init(style: Style) {
        self.init(frame: Self.defaultFrame, color: Self.defaultColor, style: style)
    }

    /// Creates a color well with the given color.
    ///
    /// - Parameter color: The initial value of the color well's color.
    public convenience init(color: NSColor) {
        self.init(frame: Self.defaultFrame, color: color)
    }

    /// Creates a color well with the given `CoreGraphics` color.
    ///
    /// - Parameter cgColor: The initial value of the color well's color.
    public convenience init?(cgColor: CGColor) {
        guard let color = NSColor(cgColor: cgColor) else {
            return nil
        }
        self.init(color: color)
    }

    /// Creates a color well with the given `CoreImage` color.
    ///
    /// - Parameter ciColor: The initial value of the color well's color.
    public convenience init(ciColor: CIColor) {
        self.init(color: NSColor(ciColor: ciColor))
    }

    #if canImport(SwiftUI)
    /// Creates a color well with the given `SwiftUI` color.
    ///
    /// - Parameter color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public convenience init(_ color: Color) {
        self.init(color: NSColor(color))
    }
    #endif

    /// Creates a color well from data in the given coder object.
    ///
    /// - Parameter coder: The coder object that contains the color
    ///   well's configuration details.
    public required init?(coder: NSCoder) {
        color = Self.defaultColor
        style = Self.defaultStyle
        super.init(coder: coder)
        sharedInit()
    }
}

// MARK: Private Instance Methods
extension ColorWell {
    /// Shared code to execute on a color well's initialization.
    private func sharedInit() {
        layoutView = ColorWellLayoutView(colorWell: self)

        addSubview(layoutView)

        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        layoutView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        layoutView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        if #available(macOS 10.14, *) {
            NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
                self?.needsDisplay = true
            }
            .store(in: &observations[for: NSApplication.self])
        }

        colorPanel.observe(\.activeColorWells, options: .new) { [weak self] _, _ in
            self?.updateActiveState()
        }
        .store(in: &observations[for: Set<ColorWell>.self])

        canSynchronizeColorPanel = true
        canExecuteChangeHandlers = true
    }

    /// Iterates through the color well's stored change handlers,
    /// executing them in the order that they were created.
    private func executeChangeHandlers() {
        guard canExecuteChangeHandlers else {
            return
        }
        for handler in changeHandlers {
            handler(color)
        }
    }

    /// Updates the `isActive` property of the color well to the
    /// current accurate value.
    private func updateActiveState() {
        _isActive = isEnabled && colorPanel.activeColorWells.contains(self)
    }

    /// Removes all observations for the color panel.
    private func removeColorPanelObservations() {
        observations[for: NSColorPanel.self].removeAll()
    }

    /// Creates a series of key-value observations that work to keep
    /// the various aspects of the color well and its color panel in
    /// sync.
    private func setUpColorPanelObservations() {
        removeColorPanelObservations()

        colorPanel.observe(\.color, options: .new) { colorPanel, change in
            guard let newValue = change.newValue else {
                return
            }
            // ???: Should every active color well be updated, even if their color already matches?
            for colorWell in colorPanel.activeColorWells where colorWell.color != newValue {
                colorWell.color = newValue
            }
        }
        .store(in: &observations[for: NSColorPanel.self])

        colorPanel.observe(\.isVisible, options: .new) { [weak self] _, change in
            guard
                let self,
                let newValue = change.newValue
            else {
                return
            }
            if !newValue {
                self.deactivate()
            }
        }
        .store(in: &observations[for: NSColorPanel.self])
    }
}

// MARK: Internal Instance Methods
extension ColorWell {
    /// Performs the specified block of code, ensuring that the color
    /// well's stored change handlers are not executed.
    internal func withoutExecutingChangeHandlers<T>(_ body: (ColorWell) throws -> T) rethrows -> T {
        let cached = canExecuteChangeHandlers
        canExecuteChangeHandlers = false
        defer {
            canExecuteChangeHandlers = cached
        }
        return try body(self)
    }

    /// Performs the specified block of code, ensuring that the color
    /// well's color panel is not synchronized.
    internal func withoutSynchronizingColorPanel<T>(_ body: (ColorWell) throws -> T) rethrows -> T {
        let cached = canSynchronizeColorPanel
        canSynchronizeColorPanel = false
        defer {
            canSynchronizeColorPanel = cached
        }
        return try body(self)
    }

    /// Activates the color well, automatically verifying whether it
    /// should be activated in an exclusive state.
    internal func activateAutoVerifyingExclusive() {
        let exclusive = !(NSEvent.modifierFlags.contains(.shift) && allowsMultipleSelection)
        activate(exclusive: exclusive)
    }

    /// Sets the color panel's color to be equal to the color
    /// well's color.
    internal func synchronizeColorPanel(force: Bool = false) {
        guard !force else {
            colorPanel.color = color
            return
        }

        guard canSynchronizeColorPanel else {
            return
        }

        if shouldSynchronizeShowsAlpha {
            colorPanel.showsAlpha = showsAlpha
            shouldSynchronizeShowsAlpha = false
        }

        guard colorPanel.color != color else {
            return
        }

        if colorPanel.activeColorWells == [self] {
            synchronizeColorPanel(force: true)
        } else {
            color = colorPanel.color
        }
    }
}

// MARK: Public Instance Methods
extension ColorWell {
    /// Activates the color well and displays its color panel.
    ///
    /// Both elements will remain synchronized until either the color panel
    /// is closed, or the color well is deactivated.
    ///
    /// - Parameter exclusive: If this value is `true`, all other active
    ///   color wells attached to this color well's color panel will be
    ///   deactivated.
    public func activate(exclusive: Bool) {
        guard isEnabled else {
            return
        }

        if exclusive {
            for colorWell in colorPanel.activeColorWells where colorWell !== self {
                colorWell.deactivate()
            }
        }

        colorPanel.activeColorWells.insert(self)
        synchronizeColorPanel()
        setUpColorPanelObservations()
        colorPanel.orderFront(self)
    }

    /// Deactivates the color well, detaching it from its color panel.
    ///
    /// Until the color well is activated again, changes to its color
    /// panel will not affect its state.
    public func deactivate() {
        colorPanel.activeColorWells.remove(self)
        swatchSegment.state = .default
        toggleSegment.state = .default
        removeColorPanelObservations()
    }

    /// Adds an action to perform when the color well's color changes.
    ///
    /// ```swift
    /// let colorWell = ColorWell()
    /// let textView = NSTextView()
    /// // ...
    /// // ...
    /// // ...
    /// colorWell.onColorChange { color in
    ///     textView.textColor = color
    /// }
    /// ```
    ///
    /// - Parameter action: A block of code that will be executed when
    ///   the color well's color changes.
    public func onColorChange(perform action: @escaping (NSColor) -> Void) {
        changeHandlers.appendUnique(IdentifiableAction(body: action))
    }
}

// MARK: Overrides
extension ColorWell {
    internal override var customAlignmentRectInsets: NSEdgeInsets {
        NSEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
    }

    internal override var customIntrinsicContentSize: NSSize {
        let result: NSSize

        switch style {
        case .expanded:
            result = Self.defaultFrame.size
        case .swatches, .colorPanel:
            result = NSSize(
                width: Self.defaultFrame.width - 20,
                height: Self.defaultFrame.height
            )
        }

        return result.applying(insets: alignmentRectInsets)
    }

    internal override func provideValue(forAttribute attribute: NSAccessibility.Attribute) -> Any? {
        switch attribute {
        case .children:
            return [toggleSegment]
        case .enabled:
            return isEnabled
        case .value:
            return color.createAccessibilityValue()
        default:
            return nil
        }
    }

    internal override func performAction(forType type: NSAccessibility.Action) -> Bool {
        switch type {
        case .press:
            swatchSegment.performAction()
            return true
        default:
            return false
        }
    }
}
