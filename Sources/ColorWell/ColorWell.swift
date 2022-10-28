//===----------------------------------------------------------------------===//
//
// ColorWell.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

#if canImport(SwiftUI)
import SwiftUI
#endif

public class _ColorWell: NSView {
  static let defaultWidth: CGFloat = 64
  static let defaultHeight: CGFloat = 28
  
  static let lineWidth: CGFloat = 1
  
  static let defaultFrame = NSRect(
    origin: .zero,
    size: .init(width: defaultWidth, height: defaultHeight))
  
  public override var intrinsicContentSize: NSSize {
    Self.defaultFrame.size
  }
  
  public override var alignmentRectInsets: NSEdgeInsets {
    .init(top: 2, left: 3, bottom: 2, right: 3)
  }
  
  var defaultShadow: NSShadow {
    let shadow = NSShadow()
    if NSApp.effectiveAppearanceIsDarkAppearance {
      shadow.shadowBlurRadius = Self.lineWidth / 2
      shadow.shadowColor = .shadowColor.withAlphaComponent(0.66)
    } else {
      shadow.shadowBlurRadius = Self.lineWidth
      shadow.shadowColor = .shadowColor.withAlphaComponent(0.5)
    }
    return shadow
  }
  
  public override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    shadow = defaultShadow
  }
}

// MARK: - ColorWell

/// A view that displays a user-settable color value.
///
/// Color wells enable custom color selection within an interface. For
/// example, a drawing app might include a color well to let someone choose
/// the color to use when drawing. Color wells display the currently selected
/// color, and interactions with the color well display interfaces for
/// selecting new colors.
public class ColorWell: _ColorWell {
  
  // MARK: Default values
  
  static let cornerRadius: CGFloat = 15
  
  static let defaultColor = NSColor.white
  
  /// Hexadecimal codes for the default colors shown in the popover.
  private static let defaultHexCodes = [
    "56C1FF", "72FDEA", "88FA4F", "FFF056", "FF968D", "FF95CA",
    "00A1FF", "15E6CF", "60D937", "FFDA31", "FF644E", "FF42A1",
    "0076BA", "00AC8E", "1FB100", "FEAE00", "ED220D", "D31876",
    "004D80", "006C65", "017101", "F27200", "B51800", "970E53",
    "FFFFFF", "D5D5D5", "929292", "5E5E5E", "000000",
  ]
  
  // MARK: Subviews
  
  private var containerGridView: ColorWellSegmentContainerGridView!
  
  // MARK: Observations and handlers
  
  private var colorPanelColorObservation: NSKeyValueObservation?
  private var colorPanelVisibilityObservation: NSKeyValueObservation?
  var changeHandlers = Set<ChangeHandler>()
  
  var sortedChangeHandlers: [ChangeHandler] {
    changeHandlers.sorted(by: <)
  }
  
  // MARK: Segments
  
  /// The segment that shows the color well's popover.
  fileprivate var popoverSegment: ColorWellSegment {
    containerGridView.popoverSegment
  }
  
  /// The segment that opens the color well's color panel.
  fileprivate var colorPanelSegment: ColorWellSegment {
    containerGridView.colorPanelSegment
  }
  
  // MARK: Misc
  
  /// The popover associated with the color well.
  fileprivate var popover: ColorWellPopover? {
    get { popoverSegment.popover }
    set { popoverSegment.popover = newValue }
  }
  
  private var _isActive = false {
    didSet {
      guard isEnabled else {
        _isActive = false
        return
      }
      
      if _isActive {
        colorPanel.activeColorWells.insert(self)
        
        colorPanelColorObservation = colorPanel.observe(
          \.color,
           options: .new
        ) { colorPanel, change in
          guard let newValue = change.newValue else {
            return
          }
          for colorWell in colorPanel.activeColorWells {
            colorWell.color = newValue
          }
        }
        
        colorPanelVisibilityObservation = colorPanel.observe(
          \.isVisible,
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
      } else {
        colorPanel.activeColorWells.remove(self)
        colorPanelSegment.setDefaultFillColorIfColorPanelSegment()
        
        colorPanelColorObservation = nil
        colorPanelVisibilityObservation = nil
      }
    }
  }
  
  // MARK: Public properties
  
  /// The color panel controlled by the color well.
  public var colorPanel = NSColorPanel.shared
  
  /// A Boolean value that indicates whether the color well is enabled.
  ///
  /// If `false`, the color well will not react to mouse events, open
  /// its color panel, or show its popover.
  public var isEnabled: Bool = true {
    didSet {
      needsDisplay = true
    }
  }
  
  /// The color well's color.
  ///
  /// Setting this value immediately updates the visual state of both
  /// the color well and its color panel, and executes all change
  /// handlers stored by the color well.
  @objc dynamic
  public var color = ColorWell.defaultColor {
    didSet {
      synchronizeVisualState()
      for handler in sortedChangeHandlers {
        handler(color)
      }
      setAccessibilityValue(color.createAccessibilityValue())
    }
  }
  
  /// A Boolean value that indicates whether the color well is currently active.
  ///
  /// - Note: This property is read-only. To activate the color well,
  ///   use ``activate(_:)``. To deactivate it, use ``deactivate()``.
  public var isActive: Bool { _isActive }
  
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
  public var swatchColors: [NSColor] = defaultHexCodes.compactMap {
    .init(hexString: $0)
  }
  
  // MARK: Initializers
  
  /// Creates a color well with the given frame rectangle.
  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    sharedInit()
  }
  
  /// Creates a color well with the default frame.
  public convenience init() {
    self.init(frame: Self.defaultFrame)
  }
  
  /// Creates a color well with the given color.
  public convenience init(color: NSColor) {
    self.init()
    self.color = color
    synchronizeVisualState()
  }
  
  /// Creates a color well with the given CoreGraphics color.
  public convenience init?(cgColor: CGColor) {
    guard let color = NSColor(cgColor: cgColor) else {
      return nil
    }
    self.init(color: color)
  }
  
  /// Creates a color well with the given CoreImage color.
  public convenience init(ciColor: CIColor) {
    self.init(color: .init(ciColor: ciColor))
  }
  
  #if canImport(SwiftUI)
  /// Creates a color well with the given SwiftUI color.
  @available(macOS 11.0, *)
  public convenience init(_ color: Color) {
    self.init(color: .init(color))
  }
  #endif
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    sharedInit()
  }
  
  func sharedInit() {
    containerGridView = .init(colorWell: self)
    
    addSubview(containerGridView)
    
    containerGridView.translatesAutoresizingMaskIntoConstraints = false
    containerGridView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    containerGridView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    containerGridView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    containerGridView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    setAccessibilityRole(.colorWell)
    setAccessibilityValue(color.createAccessibilityValue())
  }
  
  // MARK: Methods
  
  /// Sets the popover segment's fill color to be equal to the
  /// color well's color, if it isn't already.
  func synchronizePopoverSegment() {
    if popoverSegment.fillColor != color {
      popoverSegment.fillColor = color
    }
  }
  
  /// Sets the color panel's color to be equal to the color well's
  /// color, if it isn't already.
  func synchronizeColorPanel() {
    if colorPanel.color != color {
      colorPanel.color = color
    }
  }
  
  /// Sets the popover segment's fill color, and the color panel's
  /// color to be equal to the color well's color, if they aren't
  /// already.
  func synchronizeVisualState() {
    synchronizeColorPanel()
    synchronizePopoverSegment()
  }
  
  /// Activates the color well and displays its color panel.
  ///
  /// Both elements will remain synchronized until either the color
  /// panel is closed, or the color well is deactivated.
  ///
  /// - Parameter exclusive: If this value is `true`, all other active
  ///   color wells attached to this well's color panel will be
  ///   deactivated. If this value is `false`, this color well will
  ///   become active alongside the wells that are currently active.
  public func activate(_ exclusive: Bool) {
    guard isEnabled else {
      return
    }
    
    synchronizeVisualState()
    colorPanel.orderFrontRegardless()
    if exclusive {
      for colorWell in colorPanel.activeColorWells where colorWell !== self {
        colorWell.deactivate()
      }
    }
    _isActive = true
  }
  
  /// Deactivates the color well, detaching it from its color panel.
  ///
  /// Until the color well is activated again, changes to its color
  /// panel will not affect it.
  public func deactivate() {
    _isActive = false
  }
  
  /// Adds a change handler to the color well that will be executed
  /// when its color changes.
  ///
  /// ```swift
  /// let colorWell = ColorWell()
  /// let textField = NSTextField()
  ///
  /// colorWell.observeColor { newColor in
  ///     textField.textColor = newColor
  /// }
  /// ```
  ///
  /// - Parameter handler: A closure that will be executed when color
  ///   well's color changes.
  public func observeColor(onChange handler: @escaping (NSColor) -> Void) {
    changeHandlers.insert(ChangeHandler(handler: handler))
  }
}

// MARK: - ColorWellSegmentContainerGridView

/// A grid view that displays color well segments side by side.
class ColorWellSegmentContainerGridView: NSGridView {
  /// The segment that, when pressed, shows the color well's popover.
  let popoverSegment: ColorWellSegment
  
  /// The segment that, when pressed, opens the color well's color panel.
  let colorPanelSegment: ColorWellSegment
  
  var bezelLayer: CAGradientLayer?
  
  /// Creates a grid view with the given color well.
  init(colorWell: ColorWell) {
    popoverSegment = .init(colorWell: colorWell, kind: .showsPopover)
    colorPanelSegment = .init(colorWell: colorWell, kind: .opensColorPanel)
    super.init(frame: .zero)
    wantsLayer = true
    columnSpacing = 0
    xPlacement = .fill
    yPlacement = .fill
    addRow(with: [popoverSegment, colorPanelSegment])
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    bezelLayer?.removeFromSuperlayer()
    
    guard let layer else {
      return
    }
    
    bezelLayer = .init()
    
    guard let bezelLayer else {
      return
    }
    
    bezelLayer.colors = [
      CGColor.clear,
      CGColor.clear,
      CGColor.clear,
      CGColor(gray: 1, alpha: 0.25)
    ]
    bezelLayer.needsDisplayOnBoundsChange = true
    bezelLayer.frame = layer.bounds
    
    let maskLayer = CAShapeLayer()
    maskLayer.fillColor = .clear
    maskLayer.strokeColor = .black
    maskLayer.lineWidth = ColorWell.lineWidth
    maskLayer.needsDisplayOnBoundsChange = true
    maskLayer.frame = bezelLayer.frame
    maskLayer.path = Path.colorWellPath(
      for: bezelLayer.frame.insetBy(
        dx: ColorWell.lineWidth / 2,
        dy: ColorWell.lineWidth / 2)
    ).cgMutablePath
    
    bezelLayer.mask = maskLayer
    
    layer.addSublayer(bezelLayer)
  }
}

// MARK: - ColorWellSegmentKind

/// Constants that specify the kind of a segment in a color well.
enum ColorWellSegmentKind: CaseIterable {
  case opensColorPanel
  case showsPopover
}

// MARK: - ColorWellSegment

/// A view that somewhat mimics the appearance of a segment
/// in a segmented control.
class ColorWellSegment: NSView {
  weak var colorWell: ColorWell?
  
  let kind: ColorWellSegmentKind
  
  private var mouseEnteredAndExitedTrackingArea: NSTrackingArea?
  
  private var appearanceObservation: NSKeyValueObservation?
  
  private var downArrowView: NSView?
  private var colorPanelImageLayer: CALayer?
  
  var popover: ColorWellPopover?
  var canShowPopover = false
  
  /// Whether or not showing the popover should be overridden.
  var overrideShowPopover: Bool {
    kind == .showsPopover && (colorWell?.swatchColors ?? []).isEmpty
  }
  
  /// The color well's current height.
  var colorWellHeight: CGFloat {
    colorWell?.frame.height ?? ColorWell.defaultHeight
  }
  
  /// A Boolean value that indicates whether the color well is enabled.
  var colorWellIsEnabled: Bool {
    colorWell?.isEnabled ?? false
  }
  
  /// An image of a downward-facing chevron inside a translucent circle.
  var downArrowImage: NSImage {
    let sizeConstant: CGFloat = 12
    return .init(
      size: .init(width: sizeConstant, height: sizeConstant),
      flipped: false
    ) { bounds in
      NSGraphicsContext.saveGraphicsState()
      defer {
        NSGraphicsContext.restoreGraphicsState()
      }
      let circlePath = NSBezierPath(ovalIn: bounds)
      NSColor(
        srgbRed: 0.235,
        green: 0.235,
        blue: 0.235,
        alpha: 0.4
      ).setFill()
      circlePath.fill()
      
      let arrowPathBounds = NSRect(
        x: 0,
        y: 0,
        width: sizeConstant * 0.5,
        height: (sizeConstant * 0.5) / 2
      ).centered(in: bounds)
      let arrowPath = NSBezierPath()
      arrowPath.lineWidth = 1.5
      arrowPath.lineCapStyle = .round
      arrowPath.move(
        to: .init(
          x: arrowPathBounds.minX,
          y: arrowPathBounds.maxY - (arrowPath.lineWidth / 4)))
      arrowPath.line(
        to: .init(
          x: arrowPathBounds.midX,
          y: arrowPathBounds.minY - (arrowPath.lineWidth / 4)))
      arrowPath.line(
        to: .init(
          x: arrowPathBounds.maxX,
          y: arrowPathBounds.maxY - (arrowPath.lineWidth / 4)))
      
      NSColor.white.setStroke()
      arrowPath.stroke()
      
      return true
    }
  }
  
  /// The default fill color for a segment.
  var defaultFillColor: NSColor { .buttonColor }
  
  /// The fill color of the segment. Setting this value automatically
  /// redraws the segment.
  lazy var fillColor = defaultFillColor {
    didSet {
      needsDisplay = true
    }
  }
  
  /// Creates a color well segment for the given color well, with
  /// the given `ColorWellSegmentKind`.
  init(colorWell: ColorWell, kind: ColorWellSegmentKind) {
    self.kind = kind
    super.init(frame: .zero)
    self.colorWell = colorWell
    
    switch kind {
    case .opensColorPanel:
      // Constraining this segment's width will force
      // the other segment to fill the remaining space.
      translatesAutoresizingMaskIntoConstraints = false
      widthAnchor.constraint(equalToConstant: 20).isActive = true
      setAccessibilityHelp("Opens the system color panel")
    case .showsPopover:
      fillColor = colorWell.color
      setAccessibilityHelp("Shows a color selection popover")
    }
    
    if #available(macOS 10.14, *) {
      appearanceObservation = NSApp.observe(
        \.effectiveAppearance,
         options: .new
      ) { [weak self] _, _ in
        self?.needsDisplay = true
      }
    }
    
    setAccessibilityRole(.button)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func accessibilityValue() -> Any? {
    switch kind {
    case .opensColorPanel:
      return nil
    case .showsPopover:
      return colorWell?.accessibilityValue()
    }
  }
  
  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let mouseEnteredAndExitedTrackingArea {
      removeTrackingArea(mouseEnteredAndExitedTrackingArea)
    }
    mouseEnteredAndExitedTrackingArea = .init(
      rect: bounds,
      options: [
        .activeInKeyWindow,
        .mouseEnteredAndExited,
      ],
      owner: self)
    // Force unwrap is fine, as we just set this value.
    addTrackingArea(mouseEnteredAndExitedTrackingArea!)
  }
  
  /// Adds a layer that contains an image indicating that the
  /// segment opens the color panel.
  func setColorPanelImageLayer(clip: Bool = false) {
    colorPanelImageLayer?.removeFromSuperlayer()
    // Force unwrap is okay here.
    // The image name is baked in as part of Cocoa.
    let image = NSImage(named: NSImage.touchBarColorPickerFillName)!
    wantsLayer = true
    guard let layer else {
      return
    }
    colorPanelImageLayer = .init()
    guard let colorPanelImageLayer else {
      return
    }
    let imageDimension = min(layer.bounds.width, layer.bounds.height) - 5
    colorPanelImageLayer.frame = .init(
      x: 0,
      y: 0,
      width: imageDimension,
      height: imageDimension
    ).centered(in: layer.bounds)
    colorPanelImageLayer.contents = clip ? image.clippedToCircle() : image
    layer.addSublayer(colorPanelImageLayer)
  }
  
  /// Creates an image view that contains a downward-facing arrow.
  func makeDownArrowView() -> NSView {
    let view = NSImageView(image: downArrowImage)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  /// Creates a `ColorWellPopover`.
  func makePopover() -> ColorWellPopover? {
    if let colorWell {
      return .init(colorWell: colorWell)
    }
    return nil
  }
  
  /// Returns the default path that will be used to draw the
  /// segment, created based on the segment's `kind` property.
  func defaultPath(for dirtyRect: NSRect) -> NSBezierPath {
    switch kind {
    case .opensColorPanel:
      return Path.colorWellPath(
        for: dirtyRect,
        flatteningCorners: [\.topLeft, \.bottomLeft]
      ).nsBezierPath
    case .showsPopover:
      return Path.colorWellPath(
        for: dirtyRect,
        flatteningCorners: [\.topRight, \.bottomRight]
      ).nsBezierPath
    }
  }
  
  /// Activates the app and runs the color well's `activate(_:)`
  /// method, which opens the color panel and runs some observations
  /// on it.
  func openAndObserveColorPanel() {
    // Make sure we still hold a reference to the color well.
    // We don't want to show the color panel if it won't be
    // linked to the color well.
    guard let colorWell else {
      return
    }
    // Activate to make sure the color panel shows up at the front.
    NSApp.activate(ignoringOtherApps: true)
    colorWell.activate(false)
  }
  
  /// Ensures that the `canShowPopover` property is `true`,
  /// then runs `makePopover()` and displays the result.
  func makeAndShowPopover() {
    // This property will have been set on mouseDown.
    guard canShowPopover else {
      return
    }
    // The popover should be nil no matter what here.
    assert(popover == nil, "Popover should not exist yet.")
    popover = makePopover()
    guard let popover else {
      return
    }
    // The popover _shouldn't_ be shown, but check for it just in case.
    if popover.isShown {
      popover.close()
    } else {
      popover.show(relativeTo: frame, of: self, preferredEdge: .minY)
    }
  }
  
  /// Sets the fill color to a subtly highlighted version of itself,
  /// if this segment is the segment that opens the color panel.
  /// Otherwise, this function returns early.
  ///
  /// - Note: The color well's `isActive` property will be checked
  ///   before running this function. If its value is `false`, this
  ///   function will return early.
  func rollOverIfColorPanelSegment() {
    guard
      kind == .opensColorPanel,
      let colorWell,
      !colorWell.isActive
    else {
      return
    }
    if #available(macOS 10.14, *) {
      fillColor = defaultFillColor.withSystemEffect(.rollover)
    } else {
      fillColor = defaultFillColor.blended(withFraction: 0.25, of: .black)
      ?? fillColor
    }
  }
  
  /// Sets the fill color to a highlighted version of itself, if this
  /// segment is the segment that opens the color panel. Otherwise,
  /// this function returns early.
  ///
  /// - Note: The color well's `isActive` property will be checked
  ///   before running this function. If its value is `false`, this
  ///   function will return early.
  func highlightIfColorPanelSegment() {
    guard
      kind == .opensColorPanel,
      let colorWell,
      !colorWell.isActive
    else {
      return
    }
    if #available(macOS 10.14, *) {
      switch NSColor.currentControlTint {
      case .graphiteControlTint:
        // The graphite control color is almost indistinguishable
        // from the button color, so give it a "pressed" effect to
        // make it more pronounced.
        fillColor = .controlAccentColor.withSystemEffect(.pressed)
      default:
        fillColor = .controlAccentColor
      }
    } else {
      fillColor = fillColor.blended(withFraction: 0.25, of: .white)
      ?? fillColor
    }
  }
  
  /// Sets the fill color to the default fill color, if this segment
  /// is the segment that opens the color panel. Otherwise, sets the
  /// fill color to the color well's color.
  ///
  /// - Note: The color well's `isActive` property will be checked
  ///   before running this function. If its value is `false`, this
  ///   function will return early.
  func setDefaultFillColorIfColorPanelSegment() {
    guard
      let colorWell,
      !colorWell.isActive
    else {
      return
    }
    switch kind {
    case .opensColorPanel:
      fillColor = defaultFillColor
    case .showsPopover:
      fillColor = colorWell.color
    }
  }
  
  /// Adds the "down arrow" image view to this segment, if it is the
  /// segment that shows the popover. Otherwise, ensures that the segment
  /// does not contain the "down arrow" image view, and returns early.
  func addDownArrowViewIfPopoverSegment() {
    guard kind == .showsPopover else {
      downArrowView?.removeFromSuperview()
      return
    }
    
    downArrowView = makeDownArrowView()
    guard let downArrowView else {
      return
    }
    
    addSubview(downArrowView)
    downArrowView.trailingAnchor.constraint(
      equalTo: trailingAnchor,
      constant: -2.5
    ).isActive = true
    downArrowView.centerYAnchor.constraint(
      equalTo: centerYAnchor
    ).isActive = true
  }
  
  override func draw(_ dirtyRect: NSRect) {
    NSGraphicsContext.saveGraphicsState()
    defer {
      NSGraphicsContext.restoreGraphicsState()
    }
    if kind == .opensColorPanel {
      setColorPanelImageLayer(clip: true)
    }
    if colorWellIsEnabled {
      fillColor.setFill()
      colorPanelImageLayer?.opacity = 1
    } else {
      let disabledAlpha = max(fillColor.alphaComponent - 0.5, 0)
      fillColor.withAlphaComponent(disabledAlpha).setFill()
      colorPanelImageLayer?.opacity = 0.5
    }
    defaultPath(for: dirtyRect).fill()
  }
  
  override func mouseEntered(with event: NSEvent) {
    super.mouseEntered(with: event)
    guard colorWellIsEnabled else {
      return
    }
    switch kind {
    case .opensColorPanel:
      rollOverIfColorPanelSegment()
    case .showsPopover:
      if !overrideShowPopover {
        addDownArrowViewIfPopoverSegment()
      }
    }
    needsDisplay = true
  }
  
  override func mouseExited(with event: NSEvent) {
    super.mouseExited(with: event)
    guard colorWellIsEnabled else {
      return
    }
    switch kind {
    case .opensColorPanel:
      setDefaultFillColorIfColorPanelSegment()
    case .showsPopover:
      // Run this regardless of whether or not overrideShowPopover
      // is true, to ensure the arrow view is always removed.
      downArrowView?.removeFromSuperview()
      downArrowView = nil
    }
    needsDisplay = true
  }
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    guard colorWellIsEnabled else {
      return
    }
    switch kind {
    case .opensColorPanel:
      highlightIfColorPanelSegment()
    case .showsPopover:
      if !overrideShowPopover {
        // If the popover is not nil, it means that the user is clicking
        // the segment to dismiss the popover. If this is the case, don't
        // show the popover on mouse up.
        //
        // NOTE: Once the popover is dismissed, it will be asynchronously
        // nullified, so there's no need to do anything extra here.
        canShowPopover = popover == nil
      }
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    guard colorWellIsEnabled else {
      return
    }
    switch kind {
    case .opensColorPanel:
      openAndObserveColorPanel()
    case .showsPopover:
      if overrideShowPopover {
        // Pass these through to the other segment, as things
        // won't work right if we try to do it from this one.
        colorWell?.colorPanelSegment.highlightIfColorPanelSegment()
        colorWell?.colorPanelSegment.openAndObserveColorPanel()
      } else {
        makeAndShowPopover()
      }
    }
  }
}

/// A popover that contains a grid of selectable color swatches.
class ColorWellPopover: NSPopover, NSPopoverDelegate {
  weak var colorWell: ColorWell?
  
  /// The popover's content view controller.
  let popoverViewController: ColorWellPopoverViewController
  
  /// The swatches that will be shown in the popover.
  var swatches: [ColorSwatch] {
    get { popoverViewController.swatches }
    set { popoverViewController.swatches = newValue }
  }
  
  /// Creates a popover for the given color well.
  init(colorWell: ColorWell) {
    popoverViewController = .init(colorWell: colorWell)
    super.init()
    self.colorWell = colorWell
    contentViewController = popoverViewController
    behavior = .transient
    delegate = self
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
      preferredEdge: preferredEdge)
    for swatch in swatches {
      swatch.isSelected = swatch.color.sRGB == colorWell?.color.sRGB
    }
  }
  
  func popoverDidClose(_ notification: Notification) {
    // Async so that ColorWellSegment's mouseDown method
    // has a chance to run before the popover becomes nil.
    DispatchQueue.main.async { [weak colorWell] in
      colorWell?.popover = nil
    }
  }
}

/// A view controller that controls a view that contains a grid
/// of selectable color swatches.
class ColorWellPopoverViewController: NSViewController {
  /// The swatches that will be shown in the popover.
  var swatches: [ColorSwatch] {
    get { (view as? ColorWellPopoverContainerView)?.swatches ?? [] }
    set { view = ColorWellPopoverContainerView(swatches: newValue) }
  }
  
  /// Creates a popover view controller for the given color well.
  init(colorWell: ColorWell) {
    super.init(nibName: nil, bundle: nil)
    swatches = colorWell.swatchColors.map {
      .init(color: $0, colorWell: colorWell)
    }
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/// A view that contains a grid of selectable color swatches.
class ColorWellPopoverContainerView: NSView {
  /// The swatches contained in the view.
  let swatches: [ColorSwatch]
  
  /// Creates a container view for the given swatches.
  init(swatches: [ColorSwatch]) {
    self.swatches = swatches
    super.init(frame: .zero)
    
    let gridView = ColorWellPopoverGridView(swatches: swatches)
    addSubview(gridView)
    
    // Center the grid view inside the container.
    gridView.translatesAutoresizingMaskIntoConstraints = false
    gridView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    gridView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    // Give the container a 20px padding.
    translatesAutoresizingMaskIntoConstraints = false
    widthAnchor.constraint(
      equalTo: gridView.widthAnchor,
      constant: 20
    ).isActive = true
    heightAnchor.constraint(
      equalTo: gridView.heightAnchor,
      constant: 20
    ).isActive = true
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/// A grid view that contains selectable color swatches.
class ColorWellPopoverGridView: NSGridView {
  /// The maximum number of items allowed per row in the grid view.
  var maxItemsPerRow: Int
  
  /// Creates a grid view with the given swatches, dividing them
  /// into rows based on the value of `maxItemsPerRow`.
  init(swatches: [ColorSwatch], maxItemsPerRow: Int = 6) {
    self.maxItemsPerRow = maxItemsPerRow
    super.init(frame: .zero)
    rowSpacing = 1
    columnSpacing = 1
    for row in makeRows(from: swatches) {
      addRow(with: row)
    }
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Converts the passed swatches into rows, based on the value
  /// of the `maxItemsPerRow` property.
  private func makeRows(from swatches: [ColorSwatch]) -> [[ColorSwatch]] {
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

/// A rectangular, clickable color swatch that is displayed inside
/// of a color well's popover.
///
/// When a swatch is clicked, the color well's color value is set
/// to the color value of the swatch.
class ColorSwatch: NSImageView {
  weak var colorWell: ColorWell?
  
  /// The color associated with the swatch.
  let color: NSColor
  
  private var borderLayer: CAShapeLayer?
  
  private let borderWidth: CGFloat = 2
  private let borderCornerRadius: CGFloat = 1
  
  private var _isSelected = false
  
  /// A Boolean value that indicates whether the swatch is selected.
  ///
  /// In most cases, this value is true if the swatch's color matches
  /// the color value of its respective color well. However, setting
  /// this value does not automatically update the color well, although
  /// it does automatically highlight the swatch and unhighlight its
  /// siblings.
  var isSelected: Bool {
    get { _isSelected }
    set {
      _isSelected = newValue
      if _isSelected {
        iterateOtherSwatchesInPopover(where: [\.isSelected]) {
          $0.isSelected = false
        }
      }
      updateBorder()
    }
  }
  
  /// The computed border color of the swatch, created based on
  /// its current color.
  var borderColor: CGColor {
    .init(gray: (1 - color.averageBrightness) / 4, alpha: 0.15)
  }
  
  /// The computed bezel color of the swatch.
  /// - Note: Currently, this color is always white.
  var bezelColor: CGColor { .white }
  
  /// Creates a swatch with the given color, for the given color well.
  init(color: NSColor, colorWell: ColorWell) {
    self.color = color
    // sRGB conversion prevents funky rendering of
    // system colors as swatches.
    let sRGB = color.sRGB
    let image = NSImage(color: sRGB, size: .init(width: 37, height: 20))
    super.init(frame: .init(origin: .zero, size: image.size))
    self.image = image
    self.colorWell = colorWell
    wantsLayer = true
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Returns all swatches in the popover that match the given
  /// conditions.
  private func swatches(
    matching conditions: [(ColorSwatch) -> Bool]
  ) -> [ColorSwatch] {
    colorWell?.popover?.swatches.filter { swatch in
      conditions.allSatisfy { condition in
        condition(swatch)
      }
    } ?? []
  }
  
  /// Iterates through all swatches in the popover that are not
  /// the current swatch, and executes the given block of code,
  /// provided each of the the given conditions are met.
  private func iterateOtherSwatchesInPopover(
    where conditions: [(ColorSwatch) -> Bool],
    block: (ColorSwatch) -> Void
  ) {
    let conditions = conditions + [{ $0 !== self }]
    for swatch in swatches(matching: conditions) {
      block(swatch)
    }
  }
  
  /// Updates the swatch's border according to the current value
  /// of the swatch's `isSelected` property.
  private func updateBorder() {
    guard let layer else {
      return
    }
    borderLayer?.removeFromSuperlayer()
    if isSelected {
      borderLayer = .init()
      guard let borderLayer else {
        return
      }
      borderLayer.masksToBounds = false
      borderLayer.frame = layer.bounds
      borderLayer.path = .init(
        roundedRect: layer.bounds,
        cornerWidth: borderCornerRadius,
        cornerHeight: borderCornerRadius,
        transform: nil)
      borderLayer.fillColor = .clear
      borderLayer.strokeColor = bezelColor
      borderLayer.lineWidth = borderWidth
      
      borderLayer.shadowColor = NSColor.shadowColor.cgColor
      borderLayer.shadowRadius = 0.5
      borderLayer.shadowOpacity = 0.25
      borderLayer.shadowOffset = .zero
      borderLayer.shadowPath = .init(
        roundedRect: layer.bounds.insetBy(dx: borderWidth, dy: borderWidth),
        cornerWidth: borderCornerRadius,
        cornerHeight: borderCornerRadius,
        transform: nil
      ).copy(
        strokingWithWidth: borderWidth,
        lineCap: .round,
        lineJoin: .round,
        miterLimit: 0)
      
      layer.addSublayer(borderLayer)
      layer.masksToBounds = false
      layer.borderWidth = borderWidth
      layer.borderColor = bezelColor
    } else {
      layer.masksToBounds = true
      layer.borderWidth = borderWidth
      layer.borderColor = borderColor
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    // Make sure the border's state stays synchronized whenever the
    // swatch is redrawn.
    updateBorder()
  }
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    // Setting the `isSelected` property automatically highlights the
    // swatch and unhighlights all other swatches in the grid view.
    isSelected = true
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    // Update the color well's color and close the popover.
    colorWell?.color = color
    colorWell?.popover?.close()
  }
}

/// An identifier type that can be compared by order of creation.
///
/// For identifiers `id1` and `id2`, `id1 < id2` if `id1` was created first.
struct ComparableID {
  private static var totalCount = 0
  
  let root = UUID()
  let count: Int
  
  init() {
    defer { Self.totalCount += 1 }
    count = Self.totalCount
  }
}

extension ComparableID: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.count < rhs.count
  }
}

extension ComparableID: Equatable { }

extension ComparableID: Hashable { }

/// An identifiable, hashable wrapper for a change handler
/// that is executed when a color well's color changes.
///
/// This type can be compared by order of creation.
///
/// For handlers `h1` and `h2`, `h1 < h2` if `h1` was created first.
struct ChangeHandler {
  let id: ComparableID
  let handler: (NSColor) -> Void
  
  init(id: ComparableID, handler: @escaping (NSColor) -> Void) {
    self.id = id
    self.handler = handler
  }
  
  init(handler: @escaping (NSColor) -> Void) {
    self.init(id: .init(), handler: handler)
  }
  
  func callAsFunction(_ color: NSColor) {
    handler(color)
  }
}

extension ChangeHandler: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.id < rhs.id
  }
}

extension ChangeHandler: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

extension ChangeHandler: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
