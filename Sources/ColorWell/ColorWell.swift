//===----------------------------------------------------------------------===//
//
// ColorWell.swift
//
//===----------------------------------------------------------------------===//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - ColorWellBaseView

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

// MARK: ColorWellBaseView Instance Properties
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

// MARK: ColorWellBaseView Instance Methods
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

// MARK: ColorWellBaseView Overrides
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

// MARK: ColorWellBaseView Accessibility
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

// MARK: - Constants

/// A namespace for constants shared by all instances of ``ColorWell``.
private enum Constants {
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

// MARK: - ColorWell

/// A view that displays a user-settable color value.
///
/// Color wells enable the user to select custom colors from within an app's
/// interface. A graphics app might, for example, include a color well to let
/// someone choose the fill color for a shape. Color wells display the currently
/// selected color, and interactions with the color well display interfaces
/// for selecting new colors.
public class ColorWell: _ColorWellBaseView {

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

    /// The segment that shows the color well's color.
    private var swatchSegment: SwatchSegment {
        layoutView.swatchSegment
    }

    /// The segment that toggles the color well's color panel.
    fileprivate var toggleSegment: ToggleSegment {
        layoutView.toggleSegment
    }

    /// The popover associated with the color well.
    fileprivate var popover: ColorWellPopover? {
        get { swatchSegment.popover }
        set { swatchSegment.popover = newValue }
    }

    // MARK: Internal Properties

    /// The color well's change handlers.
    internal var changeHandlers = [ChangeHandler]()

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
    public var swatchColors = Constants.defaultSwatchColors

    /// The color well's color.
    ///
    /// Setting this value immediately updates the visual state of both
    /// the color well and its color panel, and executes all change
    /// handlers stored by the color well.
    @objc dynamic
    public var color = Constants.defaultColor {
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

    // MARK: Initializers

    /// Creates a color well with the given frame rectangle and color.
    ///
    /// - Parameters:
    ///   - frameRect: The frame rectangle for the created color panel.
    ///   - color: The initial value of the color well's color.
    public init(frame frameRect: NSRect, color: NSColor) {
        super.init(frame: frameRect)
        sharedInit(color: color)
    }

    /// Creates a color well with the given frame rectangle.
    ///
    /// - Parameter frameRect: The frame rectangle for the created color panel.
    public override convenience init(frame frameRect: NSRect) {
        self.init(frame: frameRect, color: Constants.defaultColor)
    }

    /// Creates a color well initialized to a default color and frame.
    public convenience init() {
        self.init(frame: Constants.defaultFrame)
    }

    /// Creates a color well with the given color.
    ///
    /// - Parameter color: The initial value of the color well's color.
    public convenience init(color: NSColor) {
        self.init(frame: Constants.defaultFrame, color: color)
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
        super.init(coder: coder)
        sharedInit(color: Constants.defaultColor)
    }
}

// MARK: ColorWell Private Methods
extension ColorWell {
    /// Shared code to execute on a color well's initialization.
    private func sharedInit(color: NSColor) {
        layoutView = ColorWellLayoutView(colorWell: self)

        addSubview(layoutView)

        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        layoutView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        layoutView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // IMPORTANT: Color should only be set AFTER the layout view is added.
        self.color = color

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

    /// Sets the color panel's color to be equal to the color
    /// well's color.
    fileprivate func synchronizeColorPanel(force: Bool = false) {
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

// MARK: ColorWell Internal Methods
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
}

// MARK: ColorWell Public Methods
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
        changeHandlers.appendUnique(ChangeHandler(action: action))
    }
}

// MARK: ColorWell Overrides
extension ColorWell {
    internal override var customAlignmentRectInsets: NSEdgeInsets {
        NSEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
    }

    internal override var customIntrinsicContentSize: NSSize {
        Constants.defaultFrame.size.applying(insets: alignmentRectInsets)
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

// MARK: - ColorWellLayoutView

/// A grid view that displays color well segments side by side.
internal class ColorWellLayoutView: NSGridView {
    /// A segment that displays a color swatch with the color well's
    /// current color selection.
    let swatchSegment: SwatchSegment

    /// A segment that, when pressed, opens the color well's color panel.
    let toggleSegment: ToggleSegment

    /// This layer helps the color well mimic the appearance of a native
    /// macOS UI element by drawing a small bezel around the edge of the view.
    private var bezelLayer: CAGradientLayer?

    /// Creates a grid view with the given color well.
    init(colorWell: ColorWell) {
        swatchSegment = SwatchSegment(colorWell: colorWell)
        toggleSegment = ToggleSegment(colorWell: colorWell)

        super.init(frame: .zero)

        wantsLayer = true
        columnSpacing = 0
        xPlacement = .fill
        yPlacement = .fill

        addRow(with: [swatchSegment, toggleSegment])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ColorWellLayoutView Overrides
extension ColorWellLayoutView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        bezelLayer?.removeFromSuperlayer()

        guard let layer else {
            return
        }

        let bezelLayer = CAGradientLayer()
        bezelLayer.colors = [
            CGColor.clear,
            CGColor.clear,
            CGColor.clear,
            CGColor(gray: 1, alpha: 0.125),
        ]
        bezelLayer.needsDisplayOnBoundsChange = true
        bezelLayer.frame = layer.bounds

        let insetAmount = Constants.lineWidth / 2
        let bezelFrame = bezelLayer.frame.insetBy(dx: insetAmount, dy: insetAmount)

        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = .clear
        maskLayer.strokeColor = .black
        maskLayer.lineWidth = Constants.lineWidth
        maskLayer.needsDisplayOnBoundsChange = true
        maskLayer.frame = bezelLayer.frame
        maskLayer.path = .colorWellPath(rect: bezelFrame)

        bezelLayer.mask = maskLayer

        layer.addSublayer(bezelLayer)
        bezelLayer.zPosition += 1

        self.bezelLayer = bezelLayer
    }
}

// MARK: - ColorWellSegment

internal class ColorWellSegment: NSView {
    weak var colorWell: ColorWell?

    private var shadowLayer: CALayer?

    private var trackingArea: NSTrackingArea?

    /// The accumulated offset of the current series of dragging events.
    private var draggingOffset = CGSize()

    var cachedDefaultPath = CachedPath()

    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// A Boolean value that indicates whether the current dragging event,
    /// if any, is valid for starting a dragging session.
    var isValidDrag: Bool {
        max(abs(draggingOffset.width), abs(draggingOffset.height)) >= 2
    }

    var state = State.default {
        didSet {
            switch oldValue {
            case .hover:
                removeHoverIndicator()
            case .highlight:
                removeHighlightIndicator()
            case .pressed:
                removePressedIndicator()
            case .default:
                break
            }
            switch state {
            case .hover:
                drawHoverIndicator()
            case .highlight:
                drawHighlightIndicator()
            case .pressed:
                drawPressedIndicator()
            case .default:
                break
            }
        }
    }

    /// The side of the color well that this segment is on.
    var side: Side { .null }

    /// A Boolean value that indicates whether the color well is enabled.
    var colorWellIsEnabled: Bool {
        colorWell?.isEnabled ?? false
    }

    /// The default fill color of the segment.
    var defaultFillColor: NSColor { .controlColor }

    /// The unaltered fill color of the segment. Setting this value
    /// automatically redraws the segment.
    lazy var fillColor = defaultFillColor {
        didSet {
            needsDisplay = true
        }
    }

    /// The color that is displayed directly in the segment, altered
    /// from `fillColor` to reflect whether the color well is currently
    /// enabled or disabled.
    var displayColor: NSColor {
        if colorWellIsEnabled {
            return fillColor
        } else {
            let disabledAlpha = max(fillColor.alphaComponent - 0.5, 0.1)
            return fillColor.withAlphaComponent(disabledAlpha)
        }
    }

    /// Creates a segment for the given color well.
    init(colorWell: ColorWell) {
        super.init(frame: .zero)
        self.colorWell = colorWell
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ColorWellSegment Dynamic Methods

    /// Invoked to update the segment to indicate that it is
    /// being hovered over.
    @objc dynamic
    func drawHoverIndicator() { }

    /// Invoked to update the segment to indicate that is is
    /// not being hovered over.
    @objc dynamic
    func removeHoverIndicator() { }

    /// Invoked to update the segment to indicate that it is
    /// being highlighted.
    @objc dynamic
    func drawHighlightIndicator() {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            fillColor = defaultFillColor.withAlphaComponent(defaultFillColor.alphaComponent + 0.1)
        } else if let blended = defaultFillColor.blended(withFraction: 0.5, of: .selectedControlColor) {
            fillColor = blended
        } else {
            fillColor = .selectedControlColor
        }
    }

    /// Invoked to update the segment to indicate that it is
    /// not being highlighted.
    @objc dynamic
    func removeHighlightIndicator() {
        fillColor = defaultFillColor
    }

    /// Invoked to update the segment to indicate that it is
    /// being pressed.
    @objc dynamic
    func drawPressedIndicator() {
        if NSApp.effectiveAppearanceIsDarkAppearance {
            fillColor = defaultFillColor.withAlphaComponent(defaultFillColor.alphaComponent + 0.25)
        } else {
            fillColor = .selectedControlColor
        }
    }

    /// Invoked to update the segment to indicate that it is
    /// not being pressed.
    @objc dynamic
    func removePressedIndicator() {
        fillColor = defaultFillColor
    }

    /// Invoked to perform the segment's action.
    @objc dynamic
    func performAction() { }
}

// MARK: ColorWellSegment Private Methods
extension ColorWellSegment {
    /// Updates the segment's dragging offset according to the x and y
    /// deltas of the given event.
    private func updateDraggingOffset(with event: NSEvent) {
        draggingOffset.width += event.deltaX
        draggingOffset.height += event.deltaY
    }
}

// MARK: ColorWellSegment Internal Methods
extension ColorWellSegment {
    /// Returns the default path that will be used to draw the segment.
    func defaultPath(for rect: NSRect, cached: inout CachedPath) -> NSBezierPath {
        if cached.rect != rect {
            cached = CachedPath(rect: rect, side: side)
        }
        return cached.path
    }

    func addShadowLayer(for rect: NSRect) {
        shadowLayer?.removeFromSuperlayer()
        shadowLayer = nil

        guard let layer else {
            return
        }

        let shadowLayer = CALayer()

        let shadowOffset = NSSize(width: 0, height: 0)
        let shadowRadius = Constants.lineWidth * 0.75
        let shadowPath = CGPath.colorWellSegment(rect: rect, side: side)

        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = NSApp.effectiveAppearanceIsDarkAppearance ? 0.5 : 0.6
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowPath = shadowPath
        shadowLayer.shadowColor = NSColor.shadowColor.cgColor

        let mutablePath = CGMutablePath()
        mutablePath.addRect(
            rect.insetBy(
                dx: -(shadowRadius * 2) + shadowOffset.width,
                dy: -(shadowRadius * 2) + shadowOffset.height
            )
        )
        mutablePath.addPath(shadowPath)
        mutablePath.closeSubpath()

        let maskLayer = CAShapeLayer()
        maskLayer.path = mutablePath
        maskLayer.fillRule = .evenOdd

        shadowLayer.mask = maskLayer

        layer.addSublayer(shadowLayer)
        layer.masksToBounds = false

        self.shadowLayer = shadowLayer
    }
}

// MARK: ColorWellSegment Overrides
extension ColorWellSegment {
    override func draw(_ dirtyRect: NSRect) {
        displayColor.setFill()
        defaultPath(for: dirtyRect, cached: &cachedDefaultPath).fill()
        addShadowLayer(for: dirtyRect)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard colorWellIsEnabled else {
            return
        }
        if state == .default {
            state = .hover
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard colorWellIsEnabled else {
            return
        }
        if state == .hover {
            state = .default
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard colorWellIsEnabled else {
            return
        }
        state = .highlight
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        draggingOffset = .zero
        guard
            colorWellIsEnabled,
            frameConvertedToWindow.contains(event.locationInWindow)
        else {
            return
        }
        performAction()
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard colorWellIsEnabled else {
            return
        }

        updateDraggingOffset(with: event)

        guard
            !isActive,
            isValidDrag
        else {
            return
        }

        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else {
            state = .default
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [
                .activeInKeyWindow,
                .mouseEnteredAndExited,
            ],
            owner: self
        )
        addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
    }
}

// MARK: ColorWellSegment Accessibility
extension ColorWellSegment {
    override func accessibilityParent() -> Any? {
        colorWell
    }

    override func accessibilityPerformPress() -> Bool {
        performAction()
        return true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override func isAccessibilityElement() -> Bool {
        true
    }
}

// MARK: - ColorWellSegment CachedPath

extension ColorWellSegment {
    /// A type that contains a cached bezier path, along
    /// with the rectangle that was used to create it.
    struct CachedPath {
        /// The rectangle used to create the path.
        let rect: NSRect

        /// The cached bezier path of this instance.
        let path: NSBezierPath

        /// Creates an instance with the given rectangle and
        /// bezier path.
        init(rect: NSRect, path: NSBezierPath) {
            self.rect = rect
            self.path = path
        }

        /// Creates an instance, constructing its bezier path
        /// from the given rectangle and side.
        init(rect: NSRect, side: Side) {
            self.init(rect: rect, path: .colorWellSegment(rect: rect, side: side))
        }

        /// Creates an instance whose rectangle and bezier path
        /// are both equivalent to `zero`.
        init() {
            self.init(rect: .zero, path: NSBezierPath())
        }
    }
}

// MARK: - ColorWellSegment State

extension ColorWellSegment {
    /// A type that represents the state of a color well segment.
    enum State {
        case hover
        case highlight
        case pressed
        case `default`
    }
}

// MARK: - ToggleSegment

internal class ToggleSegment: ColorWellSegment {
    private var imageLayer: CALayer?

    override var side: Side { .right }

    override init(colorWell: ColorWell) {
        super.init(colorWell: colorWell)
        // Constraining this segment's width will force
        // the other segment to fill the remaining space.
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

// MARK: ToggleSegment Methods
extension ToggleSegment {
    /// Adds a layer that contains an image indicating that the
    /// segment opens the color panel.
    private func setImageLayer(clip: Bool = false) {
        imageLayer?.removeFromSuperlayer()
        imageLayer = nil

        guard let layer else {
            return
        }

        // Force unwrap is okay here, as the image ships with Cocoa.
        var image = NSImage(named: NSImage.touchBarColorPickerFillName)!

        if state == .highlight {
            image = NSApp.effectiveAppearanceIsDarkAppearance
            ? image.tinted(to: .white, amount: 0.33)
            : image.tinted(to: .black, amount: 0.2)
        }

        let dimension = min(layer.bounds.width, layer.bounds.height) - 5.5
        let imageLayer = CALayer()

        imageLayer.frame = NSRect(
            x: 0,
            y: 0,
            width: dimension,
            height: dimension
        ).centered(in: layer.bounds)

        imageLayer.contents = clip ? image.clippedToCircle() : image

        if !colorWellIsEnabled {
            imageLayer.opacity = 0.5
        }

        layer.addSublayer(imageLayer)
        self.imageLayer = imageLayer
    }
}

// MARK: ToggleSegment Overrides
extension ToggleSegment {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setImageLayer(clip: true)
    }

    override func performAction() {
        guard let colorWell else {
            return
        }
        if colorWell.isActive {
            colorWell.deactivate()
            state = .default
        } else {
            let exclusive = !(NSEvent.modifierFlags.contains(.shift) && colorWell.allowsMultipleSelection)
            colorWell.activate(exclusive: exclusive)
            state = .pressed
        }
    }
}

// MARK: ToggleSegment Accessibility
extension ToggleSegment {
    override func accessibilityLabel() -> String? {
        "color picker"
    }
}

// MARK: - SwatchSegment

internal class SwatchSegment: ColorWellSegment {
    fileprivate var popover: ColorWellPopover?

    private var caretView: CaretView?

    private var cachedBorderPath = CachedPath()

    private var canShowPopover = false

    private var overrideShowPopover: Bool {
        colorWell?.swatchColors.isEmpty ?? false
    }

    private var borderColor: NSColor {
        let displayColor = displayColor // Avoid repeated access to reduce computation overhead
        let normalizedBrightness = min(displayColor.averageBrightness, displayColor.alphaComponent)
        let alpha = min(normalizedBrightness, 0.2)
        return NSColor(white: 1 - alpha, alpha: alpha)
    }

    override var side: Side { .left }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.sRGB) ?? super.displayColor
    }

    override init(colorWell: ColorWell) {
        super.init(colorWell: colorWell)
        registerForDraggedTypes([.color])
    }
}

// MARK: SwatchSegment Methods
extension SwatchSegment {
    private func prepareForPopover() {
        guard !overrideShowPopover else {
            return
        }
        canShowPopover = popover == nil
    }

    private func makePopover() -> ColorWellPopover? {
        if let colorWell {
            return ColorWellPopover(colorWell: colorWell)
        }
        return nil
    }

    private func makeAndShowPopover() {
        // The popover should be nil no matter what here.
        assert(popover == nil, "Popover should not exist yet")
        popover = makePopover()
        popover?.show(relativeTo: frame, of: self, preferredEdge: .minY)
    }
}

// MARK: SwatchSegment Overrides
extension SwatchSegment {
    override func draw(_ dirtyRect: NSRect) {
        guard colorWellIsEnabled else {
            super.draw(dirtyRect)
            return
        }

        NSImage.drawSwatch(
            with: displayColor,
            in: dirtyRect,
            clippingTo: defaultPath(for: dirtyRect, cached: &cachedDefaultPath)
        )

        borderColor.setStroke()

        let lineWidth = Constants.lineWidth
        let borderPath = defaultPath(
            for: dirtyRect.insetBy(dx: lineWidth / 4, dy: lineWidth / 2),
            cached: &cachedBorderPath
        )
        borderPath.lineWidth = lineWidth
        borderPath.stroke()

        addShadowLayer(for: dirtyRect)
    }

    override func drawHoverIndicator() {
        guard !overrideShowPopover else {
            return
        }
        let caretView = CaretView()
        addSubview(caretView)

        caretView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        caretView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        self.caretView = caretView
    }

    override func removeHoverIndicator() {
        // Ensure the caret view is removed, regardless
        // of whether `overrideShowPopover` is true.
        caretView?.removeFromSuperview()
        caretView = nil
    }

    override func drawHighlightIndicator() { }

    override func removeHighlightIndicator() { }

    override func drawPressedIndicator() { }

    override func removePressedIndicator() { }

    override func performAction() {
        prepareForPopover()
        if overrideShowPopover {
            colorWell?.toggleSegment.state = .pressed
            colorWell?.toggleSegment.performAction()
        } else if canShowPopover {
            makeAndShowPopover()
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Ignore any subviews the segment may contain
        // (i.e. the caret view).
        frame.contains(point) ? self : nil
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        state = .hover
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard
            isValidDrag,
            let color = colorWell?.color
        else {
            return
        }
        state = .default
        NSColorPanel.dragColor(color, with: event, from: self)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard
            let types = sender.draggingPasteboard.types,
            types.contains(where: { registeredDraggedTypes.contains($0) })
        else {
            return []
        }
        return .move
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let color = NSColor(from: sender.draggingPasteboard) {
            colorWell?.color = color
            return true
        }
        return false
    }
}

// MARK: SwatchSegment Accessibility
extension SwatchSegment {
    override func isAccessibilityElement() -> Bool {
        false
    }
}

// MARK: - SwatchSegment CaretView

extension SwatchSegment {
    /// A view that contains a downward-facing caret inside of a translucent
    /// circle. This view appears when the mouse hovers over a swatch segment.
    private class CaretView: NSImageView {
        /// An image of a downward-facing caret inside of a translucent circle.
        private let caretImage = NSImage(size: NSSize(width: 12, height: 12), flipped: false) { bounds in
            NSColor(white: 0, alpha: 0.25).setFill()
            NSBezierPath(ovalIn: bounds).fill()

            let lineWidth = 1.5
            let caretPathBounds = NSRect(
                x: 0,
                y: 0,
                width: (bounds.width - lineWidth) / 2,
                height: (bounds.height - lineWidth) / 4
            ).centered(
                in: bounds
            ).offsetBy(
                dx: 0,
                dy: -lineWidth / 4
            )

            let caretPath = NSBezierPath()
            caretPath.move(
                to: NSPoint(
                    x: caretPathBounds.minX,
                    y: caretPathBounds.maxY
                )
            )
            caretPath.line(
                to: NSPoint(
                    x: caretPathBounds.midX,
                    y: caretPathBounds.minY
                )
            )
            caretPath.line(
                to: NSPoint(
                    x: caretPathBounds.maxX,
                    y: caretPathBounds.maxY
                )
            )

            NSColor.white.setStroke()

            caretPath.lineWidth = lineWidth
            caretPath.lineCapStyle = .round
            caretPath.stroke()

            return true
        }

        init() {
            super.init(frame: .zero)
            image = caretImage
            translatesAutoresizingMaskIntoConstraints = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - ColorWellPopover

/// A popover that contains a grid of selectable color swatches.
internal class ColorWellPopover: NSPopover {
    weak var colorWell: ColorWell?

    /// The popover's content view controller.
    let popoverViewController: ColorWellPopoverViewController

    /// The swatches that are shown in the popover.
    var swatches: [ColorSwatch] {
        popoverViewController.swatches
    }

    /// Creates a popover for the given color well.
    init(colorWell: ColorWell) {
        popoverViewController = ColorWellPopoverViewController(colorWell: colorWell)
        super.init()
        self.colorWell = colorWell
        contentViewController = popoverViewController
        behavior = .transient
        delegate = popoverViewController
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )
        guard
            let color = colorWell?.color,
            let swatch = swatches.first(where: { $0.color.resembles(color) })
        else {
            return
        }
        swatch.select()
    }
}

// MARK: - ColorWellPopoverViewController

/// A view controller that controls a view that contains a grid
/// of selectable color swatches.
internal class ColorWellPopoverViewController: NSViewController {
    weak var colorWell: ColorWell?

    let containerView: ColorWellPopoverContainerView

    var swatches: [ColorSwatch] {
        containerView.swatches
    }

    init(colorWell: ColorWell) {
        self.containerView = ColorWellPopoverContainerView(colorWell: colorWell)
        super.init(nibName: nil, bundle: nil)
        self.view = containerView
        self.colorWell = colorWell
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ColorWellPopoverViewController: NSPopoverDelegate
extension ColorWellPopoverViewController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        // Async so that ColorWellSegment's mouseDown method
        // has a chance to run before the popover becomes nil.
        DispatchQueue.main.async { [weak colorWell] in
            colorWell?.popover = nil
        }
    }
}

// MARK: - ColorWellPopoverContainerView

/// A view that contains a grid of selectable color swatches.
internal class ColorWellPopoverContainerView: NSView {
    var layoutView: ColorWellPopoverLayoutView?

    var swatches: [ColorSwatch] {
        layoutView?.swatches ?? []
    }

    init(colorWell: ColorWell) {
        super.init(frame: .zero)

        let layoutView = ColorWellPopoverLayoutView(containerView: self, colorWell: colorWell)
        addSubview(layoutView)

        // Center the layout view inside the container.
        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // Give the container a 20px padding.
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: layoutView.widthAnchor, constant: 20).isActive = true
        heightAnchor.constraint(equalTo: layoutView.heightAnchor, constant: 20).isActive = true

        self.layoutView = layoutView
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ColorWellPopoverContainerView Accessibility
extension ColorWellPopoverContainerView {
    override func accessibilityChildren() -> [Any]? {
        layoutView.map { [$0] }
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .group
    }
}

// MARK: - ColorWellPopoverLayoutView

/// A view that provides the layout for a popover's color swatches.
internal class ColorWellPopoverLayoutView: NSGridView {
    weak var containerView: ColorWellPopoverContainerView?

    private(set) var swatches = [ColorSwatch]()

    let maxItemsPerRow: Int

    var selectedSwatch: ColorSwatch? {
        swatches.first { $0.isSelected }
    }

    /// Creates a layout view with the given container view and color well,
    /// using the color well's `swatchColors` property to construct a grid
    /// of swatches.
    init(
        containerView: ColorWellPopoverContainerView,
        colorWell: ColorWell
    ) {
        self.containerView = containerView

        let swatchCount = colorWell.swatchColors.count
        maxItemsPerRow = max(4, Int(sqrt(Double(swatchCount)).rounded(.up)))

        super.init(frame: .zero)

        rowSpacing = 1
        columnSpacing = 1

        let rowCount = Int((Double(swatchCount) / Double(maxItemsPerRow)).rounded(.up))
        swatches = colorWell.swatchColors.map { color in
            ColorSwatch(rowCount: rowCount, color: color, colorWell: colorWell, layoutView: self)
        }

        for row in makeRows() {
            addRow(with: row)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ColorWellPopoverLayoutView Methods
extension ColorWellPopoverLayoutView {
    /// Converts the view's swatches into rows.
    private func makeRows() -> [[ColorSwatch]] {
        var currentRow = [ColorSwatch]()
        var rows = [[ColorSwatch]]()
        for swatch in swatches {
            if currentRow.count >= maxItemsPerRow {
                rows.append(currentRow)
                currentRow.removeAll()
            }
            currentRow.append(swatch)
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
}

// MARK: ColorWellPopoverLayoutView Overrides
extension ColorWellPopoverLayoutView {
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let swatch = swatches.first { swatch in
            swatch.frameConvertedToWindow.contains(event.locationInWindow)
        }
        swatch?.select()
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        selectedSwatch?.performAction()
    }
}

// MARK: ColorWellPopoverLayoutView Accessibility
extension ColorWellPopoverLayoutView {
    override func accessibilityParent() -> Any? {
        containerView
    }

    override func accessibilityChildren() -> [Any]? {
        swatches
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .layoutArea
    }
}

// MARK: - ColorSwatch

/// A rectangular, clickable color swatch that is displayed inside
/// of a color well's popover.
///
/// When a swatch is clicked, the color well's color value is set
/// to the color value of the swatch.
internal class ColorSwatch: NSView {
    weak var layoutView: ColorWellPopoverLayoutView?

    let colorWell: ColorWell

    let color: NSColor

    private var bezelLayer: CAShapeLayer?

    private let borderWidth: CGFloat = 2

    private let cornerRadius: CGFloat = 1

    /// A Boolean value that indicates whether the swatch is selected.
    ///
    /// In most cases, this value is true if the swatch's color matches
    /// the color value of its respective color well. However, setting
    /// this value does not automatically update the color well, although
    /// it does automatically highlight the swatch and unhighlight its
    /// siblings.
    private(set) var isSelected = false {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            defer {
                updateBezel()
            }
            guard isSelected else {
                return
            }
            iterateOtherSwatches(where: [\.isSelected]) { swatch in
                swatch.isSelected = false
            }
        }
    }

    /// The color of the swatch, converted to a standardized format
    /// for display.
    private var displayColor: NSColor {
        color.usingColorSpace(.sRGB) ?? color
    }

    /// The computed border color of the swatch, created based on its
    /// current color.
    private var borderColor: CGColor {
        CGColor(gray: (1 - color.averageBrightness) / 4, alpha: 0.15)
    }

    /// The computed bezel color of the swatch.
    /// - Note: Currently, this color is always white.
    private var bezelColor: CGColor { .white }

    /// Creates a swatch with the given color, color well, and layout view.
    init(
        rowCount: Int,
        color: NSColor,
        colorWell: ColorWell,
        layoutView: ColorWellPopoverLayoutView
    ) {
        self.color = color
        self.colorWell = colorWell
        self.layoutView = layoutView

        let size = Self.size(forRowCount: rowCount)

        super.init(frame: NSRect(origin: .zero, size: size))

        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ColorSwatch Static Methods
extension ColorSwatch {
    /// Returns the correct size for a swatch based on the row count that
    /// is passed into it. Bigger row counts result in smaller swatches.
    static func size(forRowCount rowCount: Int) -> NSSize {
        if rowCount < 6 {
            return NSSize(width: 37, height: 20)
        } else if rowCount < 10 {
            return NSSize(width: 31, height: 18)
        }
        return NSSize(width: 15, height: 15)
    }
}

// MARK: ColorSwatch Methods
extension ColorSwatch {
    /// Returns all swatches in the layout view that match the given conditions.
    private func swatches(matching conditions: [(ColorSwatch) -> Bool]) -> [ColorSwatch] {
        guard let layoutView else {
            return []
        }
        return layoutView.swatches.filter { swatch in
            conditions.allSatisfy { condition in
                condition(swatch)
            }
        }
    }

    /// Iterates through all other swatches in the layout view and executes
    /// the given block of code, provided a set of conditions are met.
    private func iterateOtherSwatches(where conditions: [(ColorSwatch) -> Bool], block: (ColorSwatch) -> Void) {
        let conditions = conditions + [{ $0 !== self }]
        for swatch in swatches(matching: conditions) {
            block(swatch)
        }
    }

    /// Updates the swatch's border according to the current value of
    /// the swatch's `isSelected` property.
    private func updateBorder() {
        layer?.borderWidth = borderWidth
        if isSelected {
            layer?.borderColor = bezelColor
        } else {
            layer?.borderColor = borderColor
        }
    }

    /// Draws a rounded bezel around the swatch, if the swatch is
    /// selected. If the swatch is not selected, its border is updated
    /// and the method returns early.
    private func updateBezel() {
        bezelLayer?.removeFromSuperlayer()
        bezelLayer = nil

        guard
            let layer,
            isSelected
        else {
            updateBorder()
            return
        }
        let bezelLayer = CAShapeLayer()

        bezelLayer.masksToBounds = false
        bezelLayer.frame = layer.bounds

        bezelLayer.path = CGPath(
            roundedRect: layer.bounds,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )

        bezelLayer.fillColor = .clear
        bezelLayer.strokeColor = bezelColor
        bezelLayer.lineWidth = borderWidth

        bezelLayer.shadowColor = NSColor.shadowColor.cgColor
        bezelLayer.shadowRadius = 0.5
        bezelLayer.shadowOpacity = 0.25
        bezelLayer.shadowOffset = .zero

        bezelLayer.shadowPath = CGPath(
            roundedRect: layer.bounds.insetBy(dx: borderWidth, dy: borderWidth),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        ).copy(
            strokingWithWidth: borderWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 0
        )

        layer.addSublayer(bezelLayer)
        layer.masksToBounds = false
        layer.borderColor = bezelColor
        layer.borderWidth = borderWidth

        self.bezelLayer = bezelLayer
    }

    /// Selects the swatch, drawing a bezel around its edges and ensuring
    /// that all other swatches in the layout view are deselected.
    func select() {
        // Setting the `isSelected` property automatically highlights the
        // swatch and unhighlights all other swatches in the layout view.
        isSelected = true
    }

    /// Performs the swatch's action, setting the color well's color to
    /// that of the swatch, and closing the popover.
    func performAction() {
        if colorWell.isActive {
            colorWell.withoutSynchronizingColorPanel { colorWell in
                colorWell.color = color
            }
            colorWell.withoutExecutingChangeHandlers { colorWell in
                colorWell.synchronizeColorPanel(force: true)
            }
        } else {
            colorWell.color = color
        }
        colorWell.popover?.close()
    }
}

// MARK: ColorSwatch Overrides
extension ColorSwatch {
    override func draw(_ dirtyRect: NSRect) {
        displayColor.drawSwatch(in: dirtyRect)
        updateBorder()
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        select()
    }
}

// MARK: ColorSwatch Accessibility
extension ColorSwatch {
    override func accessibilityLabel() -> String? {
        "color swatch"
    }

    override func accessibilityParent() -> Any? {
        layoutView
    }

    override func accessibilityPerformPress() -> Bool {
        performAction()
        return true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func isAccessibilitySelected() -> Bool {
        isSelected
    }
}
