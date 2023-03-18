//
// ColorWell.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI
#endif

/// A control that displays a user-selectable color value.
///
/// Color wells provide a means for choosing custom colors directly within
/// your app's user interface. A color well displays the currently selected
/// color, and provides options for selecting new colors. There are a number
/// of styles to choose from, each of which provides a different appearance
/// and set of behaviors.
public class ColorWell: _ColorWellBaseView {

    // MARK: Static Properties

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
    static let defaultStyle = Style.expanded

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

    // MARK: Private Properties

    /// The observations associated with the color well.
    private var observations = [ObjectIdentifier: Set<NSKeyValueObservation>]()

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

    /// A view that manages the layout of the color well's segments.
    private var layoutView: ColorWellLayoutView {
        enum Cache {
            static let storage = Storage()
        }
        return Cache.storage.value(
            forObject: self,
            default: ColorWellLayoutView(colorWell: self)
        )
    }

    // MARK: Internal Properties

    /// The color well's change handlers.
    var changeHandlers = [(NSColor) -> Void]()

    /// The popover context associated with the color well.
    var popoverContext: ColorWellPopoverContext?

    /// An optional Boolean value that, if set, will cause the system
    /// color panel to show or hide its alpha controls during the next
    /// call to `synchronizeColorPanel()`.
    var showsAlphaForcedState: Bool? {
        didSet {
            if isActive {
                synchronizeColorPanel()
            }
        }
    }

    /// A segment that shows the color well's color, and
    /// toggles the color panel when pressed.
    var colorPanelSwatchSegment: ColorPanelSwatchSegment? {
        switch style {
        case .colorPanel:
            return layoutView.colorPanelSwatchSegment
        case .expanded, .swatches:
            return nil
        }
    }

    /// A segment that shows the color well's color, and
    /// triggers a pull down action when pressed.
    var pullDownSwatchSegment: PullDownSwatchSegment? {
        switch style {
        case .expanded, .swatches:
            return layoutView.pullDownSwatchSegment
        case .colorPanel:
            return nil
        }
    }

    /// A segment that toggles the color panel when pressed.
    var toggleSegment: ToggleSegment? {
        switch style {
        case .expanded:
            return layoutView.toggleSegment
        case .swatches, .colorPanel:
            return nil
        }
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
    /// - Note: If the array is empty, the system color panel will be shown
    ///   instead of the popover.
    @objc dynamic
    public var swatchColors = defaultSwatchColors

    /// The color well's color.
    ///
    /// Setting this value immediately updates the visual state of the color well
    /// and executes its change handlers. If the color well is active, the system
    /// color panel's color is updated to match the new value.
    @objc dynamic
    public var color: NSColor {
        didSet {
            defer {
                executeChangeHandlers()
            }
            guard oldValue != color else {
                return
            }
            if
                isActive,
                NSColorPanel.shared.color != color
            {
                NSColorPanel.shared.color = color
            }
            colorPanelSwatchSegment?.needsDisplay = true
            pullDownSwatchSegment?.needsDisplay = true
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
    /// the system color panel, or show the color selection popover.
    ///
    /// Default value is `true`.
    @objc dynamic
    public var isEnabled: Bool = true {
        didSet {
            switch style {
            case .expanded:
                toggleSegment?.needsDisplay = true
            case .swatches: break
            case .colorPanel:
                colorPanelSwatchSegment?.needsDisplay = true
            }
        }
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

    // MARK: Designated Initializers

    /// Creates a color well with the specified frame, color, and style.
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

    // MARK: Convenience Initializers

    /// Creates a color well with the specified frame and color.
    ///
    /// - Parameters:
    ///   - frameRect: The frame rectangle for the created color panel.
    ///   - color: The initial value of the color well's color.
    public convenience init(frame frameRect: NSRect, color: NSColor) {
        self.init(frame: frameRect, color: color, style: Self.defaultStyle)
    }

    /// Creates a color well with the specified frame.
    ///
    /// - Parameter frameRect: The frame rectangle for the created color panel.
    public override convenience init(frame frameRect: NSRect) {
        self.init(frame: frameRect, color: Self.defaultColor)
    }

    /// Creates a color well using a default frame, color, and style.
    public convenience init() {
        self.init(frame: Self.defaultFrame)
    }

    /// Creates a color well with the specified style.
    ///
    /// - Parameter style: The style to use to display the color well.
    public convenience init(style: Style) {
        self.init(frame: Self.defaultFrame, color: Self.defaultColor, style: style)
    }

    /// Creates a color well with the specified color.
    ///
    /// - Parameter color: The initial value of the color well's color.
    public convenience init(color: NSColor) {
        self.init(frame: Self.defaultFrame, color: color)
    }

    /// Creates a color well with the specified Core Graphics color.
    ///
    /// - Parameter cgColor: The initial value of the color well's color.
    public convenience init?(cgColor: CGColor) {
        guard let color = NSColor(cgColor: cgColor) else {
            return nil
        }
        self.init(color: color)
    }

    // TODO: Replace this with an `init?(ciColor: CIColor)` signature.
    // This is a workaround to replace `init(ciColor: CIColor)`, which
    // is non-failable. Changing it to be failable, but with otherwise
    // the same signature would be a breaking change, so we need to
    // deprecate the original and wait at least one release to remove
    // it. Once it's gone, we can deprecate this initializer and
    // introduce the failable version of the original as a new API.
    //
    /// Creates a color well with the specified Core Image color.
    ///
    /// - Parameter ciColor: The initial value of the color well's color.
    public convenience init?(coreImageColor ciColor: CIColor) {
        guard let cgColor = CGColor(colorSpace: ciColor.colorSpace, components: ciColor.components) else {
            return nil
        }
        self.init(cgColor: cgColor)
    }

    #if canImport(SwiftUI)
    /// Creates a color well with the specified `SwiftUI` color.
    ///
    /// - Parameter color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public convenience init(_ color: Color) {
        self.init(color: NSColor(color))
    }
    #endif
}

// MARK: Private Instance Methods
extension ColorWell {
    /// Shared code to execute on a color well's initialization.
    private func sharedInit() {
        wantsLayer = true
        layer?.masksToBounds = false
        addSubview(layoutView)

        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        layoutView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        layoutView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        if #available(macOS 10.14, *) {
            observations[for: NSApplication.self].observe(
                NSApp,
                keyPath: \.effectiveAppearance
            ) { [weak self] _, _ in
                self?.needsDisplay = true
            }
        }

        observations[for: Set<ColorWell>.self].observe(
            NSColorPanel.shared,
            keyPath: \.activeColorWells
        ) { [weak self] _, _ in
            self?.updateActiveState()
        }
    }

    /// Executes each of the color well's stored change handlers.
    private func executeChangeHandlers() {
        for handler in changeHandlers {
            handler(color)
        }
    }

    /// Updates the `isActive` property of the color well to the
    /// current accurate value.
    private func updateActiveState() {
        _isActive = NSColorPanel.shared.activeColorWells.contains(self)
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

        observations[for: NSColorPanel.self].observe(
            NSColorPanel.shared,
            keyPath: \.color,
            options: .new
        ) { colorPanel, change in
            guard let newValue = change.newValue else {
                return
            }

            let predicate: (ColorWell) -> Bool = { colorWell in
                colorWell.isEnabled &&
                colorWell.color != newValue
            }

            for colorWell in colorPanel.activeColorWells where predicate(colorWell) {
                colorWell.color = newValue
            }
        }

        observations[for: NSColorPanel.self].observe(
            NSColorPanel.shared,
            keyPath: \.isVisible,
            options: .new
        ) { [weak self] _, change in
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
    }
}

// MARK: Internal Instance Methods
extension ColorWell {
    /// Activates the color well, automatically determining whether
    /// it should be activated in an exclusive state.
    func activateAutoVerifyingExclusive() {
        let exclusive = !(NSEvent.modifierFlags.contains(.shift) && allowsMultipleSelection)
        activate(exclusive: exclusive)
    }

    /// Synchronizes the state of the system color panel to match
    /// the state of the color well.
    func synchronizeColorPanel() {
        if let showsAlphaForcedState {
            NSColorPanel.shared.showsAlpha = showsAlphaForcedState
        }

        guard NSColorPanel.shared.color != color else {
            return
        }

        if NSColorPanel.shared.activeColorWells == [self] {
            NSColorPanel.shared.color = color
        } else {
            color = NSColorPanel.shared.color
        }
    }
}

// MARK: Public Instance Methods
extension ColorWell {
    /// Activates the color well and displays the system color panel.
    ///
    /// Both elements will remain synchronized until either the color panel
    /// is closed, or the color well is deactivated.
    ///
    /// - Parameter exclusive: If this value is `true`, all other active
    ///   color wells attached to the color panel will be deactivated.
    public func activate(exclusive: Bool) {
        guard isEnabled else {
            return
        }

        if exclusive {
            for colorWell in NSColorPanel.shared.activeColorWells where colorWell !== self {
                colorWell.deactivate()
            }
        }

        NSColorPanel.shared.activeColorWells.insert(self)
        synchronizeColorPanel()
        setUpColorPanelObservations()
        // ???: Should `NSApp.orderFrontColorPanel(self)` be used instead?
        NSColorPanel.shared.orderFront(self)
        colorPanelSwatchSegment?.state = .pressed
        toggleSegment?.state = .pressed
    }

    /// Deactivates the color well, detaching it from the system color
    /// panel.
    ///
    /// Until the color well is activated again, changes to the color
    /// panel will not affect the color well's state.
    public func deactivate() {
        NSColorPanel.shared.activeColorWells.remove(self)
        colorPanelSwatchSegment?.state = .default
        toggleSegment?.state = .default
        removeColorPanelObservations()
    }

    /// Adds an action to perform when the color well's color changes.
    ///
    /// Use this method to synchronize the state of other elements in
    /// your user interface that rely on the color well's color.
    ///
    /// ```swift
    /// colorWell.onColorChange { color in
    ///     textView.textColor = color
    /// }
    /// ```
    ///
    /// - Parameter action: A block of code that will be executed when
    ///   the color well's color changes.
    public func onColorChange(perform action: @escaping (NSColor) -> Void) {
        changeHandlers.append(action)
    }
}

// MARK: Overrides
extension ColorWell {
    override var customAlignmentRectInsets: NSEdgeInsets {
        NSEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
    }

    override var customIntrinsicContentSize: NSSize {
        let result: NSSize

        switch style {
        case .expanded:
            result = Self.defaultFrame.size
        case .swatches:
            result = Self.defaultFrame.size.insetBy(
                dx: ToggleSegment.widthConstant / 2,
                dy: 0
            )
        case .colorPanel:
            result = Self.defaultFrame.size.insetBy(
                dx: (ToggleSegment.widthConstant / 3) + 0.5,
                dy: 0.5
            )
        }

        return result.applying(insets: alignmentRectInsets)
    }

    override var customAccessibilityChildren: [Any]? {
        toggleSegment
            .map(CollectionOfOne.init)
            .map(Array.init)
    }

    override var customAccessibilityEnabled: Bool {
        isEnabled
    }

    override var customAccessibilityValue: Any? {
        color.createAccessibilityValue()
    }

    override var customAccessibilityPerformPress: () -> Bool {
        if let colorPanelSwatchSegment {
            return colorPanelSwatchSegment.performAction
        } else if let pullDownSwatchSegment {
            return pullDownSwatchSegment.performAction
        }
        return { false }
    }
}
