//===----------------------------------------------------------------------===//
//
// ColorWellView.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

#if canImport(SwiftUI)
import SwiftUI

// MARK: ColorWellWrapper

@available(macOS 10.15, *)
private struct ColorWellWrapper: NSViewRepresentable {
  let color: NSColor?

  func makeNSView(context: Context) -> ColorWell {
    if let color {
      return .init(color: color)
    } else {
      return .init()
    }
  }

  func updateNSView(_ nsView: ColorWell, context: Context) {
    nsView.changeHandlers.formUnion(context.environment.changeHandlers)
    nsView.isEnabled = context.environment.isEnabled

    if #available(macOS 11.0, *) {
      nsView.swatchColors = context.environment.swatchColors
    }
  }
}

// MARK: ColorWellView

@available(macOS 10.15, *)
public struct ColorWellView<Label: View>: View {
  private let constructor: AnyViewConstructor

  public var body: some View {
    constructor
  }

  private init<C: NSColorConvertible<C>>(
    color: NSColor?,
    label: (() -> Label)?,
    action: ((C) -> Void)?
  ) {
    constructor = ViewConstructor {
      ColorWellWrapper(color: color)
    }
    .with { view in
      if let action {
        view.modifier(OnColorChange(action: action))
      } else {
        view
      }
    }
    .with { view in
      view.fixedSize()
    }
    .with { view in
      if let label {
        HStack {
          label()
          view
        }
      } else {
        view
      }
    }
    .erased()
  }

  private init<C: NSColorConvertible<C>>(
    color: NSColor?,
    label: @autoclosure () -> Label,
    action: ((C) -> Void)?
  ) {
    let label = label()
    self.init(color: color, label: { label }, action: action)
  }

  private init(color: NSColor?, label: (() -> Label)?) {
    self.init(color: color, label: label, action: Optional<(Color) -> Void>.none)
  }

  private init(color: NSColor?, label: @autoclosure () -> Label) {
    let label = label()
    self.init(color: color, label: { label })
  }

  public init(@ViewBuilder label: () -> Label) {
    self.init(color: nil, label: label())
  }

  public init(@ViewBuilder label: () -> Label, action: @escaping (Color) -> Void) {
    self.init(color: nil, label: label(), action: action)
  }

  @available(macOS 11.0, *)
  public init(color: Color, @ViewBuilder label: () -> Label) {
    self.init(color: .init(color), label: label())
  }

  @available(macOS 11.0, *)
  public init(color: Color, @ViewBuilder label: () -> Label, action: @escaping (Color) -> Void) {
    self.init(color: .init(color), label: label(), action: action)
  }

  /// Creates a color well view with the given CoreGraphics color.
  ///
  /// - Parameter cgColor: The starting value of the color well's color.
  public init(cgColor: CGColor, @ViewBuilder label: () -> Label) {
    self.init(color: .init(cgColor: cgColor), label: label())
  }

  public init(cgColor: CGColor, @ViewBuilder label: () -> Label, action: @escaping (CGColor) -> Void) {
    self.init(color: .init(cgColor: cgColor), label: label(), action: action)
  }
}

@available(macOS 10.15, *)
extension ColorWellView<Never> {
  /// Creates a color well with the default color.
  public init() {
    self.init(color: nil, label: nil)
  }

  /// Creates a color well view with the given color.
  ///
  /// - Parameter color: The starting value of the color well's color.
  @available(macOS 11.0, *)
  public init(color: Color) {
    self.init(color: .init(color), label: nil)
  }

  /// Creates a color well that executes the given action when its color changes.
  ///
  /// This initializer has the same effect as the ``onColorChange(perform:)`` modifier.
  ///
  /// - Parameter action: An action to perform when the color well's color changes.
  public init(action: @escaping (Color) -> Void) {
    self.init(color: nil, label: nil, action: action)
  }

  /// Creates a color well view with the given color and action.
  ///
  /// This initializer has the same effect as the ``onColorChange(perform:)`` modifier.
  ///
  /// - Parameters:
  ///   - color: The starting value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  @available(macOS 11.0, *)
  public init(color: Color, action: @escaping (Color) -> Void) {
    self.init(color: .init(color), label: nil, action: action)
  }

  /// Creates a color well view with the given CoreGraphics color.
  ///
  /// - Parameter cgColor: The starting value of the color well's color.
  public init(cgColor: CGColor) {
    self.init(color: .init(cgColor: cgColor), label: nil)
  }

  /// Creates a color well view with the given CoreGraphics color.
  ///
  /// This initializer has the same effect as the ``onColorChange(perform:)`` modifier.
  ///
  /// - Note: The color well's color is translated into a `CGColor` from
  ///   an underlying representation. In some cases, the translation process
  ///   may be forced to return an approximation, rather than the original
  ///   color. To receive a color that is guaranteed to be equivalent to the
  ///   color well's underlying representation, use ``init(color:action:)``.
  ///
  /// - Parameters:
  ///   - cgColor: The starting value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  public init(cgColor: CGColor, action: @escaping (CGColor) -> Void) {
    self.init(color: .init(cgColor: cgColor), label: nil, action: action)
  }
}

@available(macOS 10.15, *)
extension ColorWellView<Text> {
  public init<S: StringProtocol>(_ title: S) {
    self.init(label: title.label)
  }

  @available(macOS 11.0, *)
  public init<S: StringProtocol>(_ title: S, color: Color) {
    self.init(color: color, label: title.label)
  }

  public init<S: StringProtocol>(_ title: S, cgColor: CGColor) {
    self.init(cgColor: cgColor, label: title.label)
  }

  public init<S: StringProtocol>(_ title: S, action: @escaping (Color) -> Void) {
    self.init(label: title.label, action: action)
  }

  @available(macOS 11.0, *)
  public init<S: StringProtocol>(_ title: S, color: Color, action: @escaping (Color) -> Void) {
    self.init(color: color, label: title.label, action: action)
  }

  public init<S: StringProtocol>(_ title: S, cgColor: CGColor, action: @escaping (CGColor) -> Void) {
    self.init(cgColor: cgColor, label: title.label, action: action)
  }

  public init(_ titleKey: LocalizedStringKey) {
    self.init(label: titleKey.label)
  }

  @available(macOS 11.0, *)
  public init(_ titleKey: LocalizedStringKey, color: Color) {
    self.init(color: color, label: titleKey.label)
  }

  public init(_ titleKey: LocalizedStringKey, cgColor: CGColor) {
    self.init(cgColor: cgColor, label: titleKey.label)
  }

  public init(_ titleKey: LocalizedStringKey, action: @escaping (Color) -> Void) {
    self.init(label: titleKey.label, action: action)
  }

  @available(macOS 11.0, *)
  public init(_ titleKey: LocalizedStringKey, color: Color, action: @escaping (Color) -> Void) {
    self.init(color: color, label: titleKey.label, action: action)
  }

  public init(_ titleKey: LocalizedStringKey, cgColor: CGColor, action: @escaping (CGColor) -> Void) {
    self.init(cgColor: cgColor, label: titleKey.label, action: action)
  }
}

// MARK: Environment Keys

@available(macOS 10.15, *)
private struct ChangeHandlersKey: EnvironmentKey {
  static let defaultValue = Set<ChangeHandler>()
}

@available(macOS 11.0, *)
private struct SwatchColorsKey: EnvironmentKey {
  static let defaultValue = ColorWell.defaultSwatchColors
}

// MARK: Environment Values

@available(macOS 10.15, *)
private extension EnvironmentValues {
  var changeHandlers: Set<ChangeHandler> {
    get { self[ChangeHandlersKey.self] }
    set { self[ChangeHandlersKey.self] = newValue }
  }
}

@available(macOS 11.0, *)
private extension EnvironmentValues {
  var swatchColors: [NSColor] {
    get { self[SwatchColorsKey.self] }
    set { self[SwatchColorsKey.self] = newValue }
  }
}

// MARK: View Modifiers

@available(macOS 10.15, *)
private struct OnColorChange<C: NSColorConvertible<C>>: ViewModifier {
  let id = ComparableID()
  let action: (C.Converted) -> Void

  var transformedAction: ChangeHandler {
    ChangeHandler(id: id) {
      action(C.converted(from: $0))
    }
  }

  func body(content: Content) -> some View {
    content.transformEnvironment(\.changeHandlers) {
      $0.insert(transformedAction)
    }
  }
}

@available(macOS 11.0, *)
private struct SwatchColors: ViewModifier {
  let colors: [Color]

  var transformedColors: [NSColor] {
    colors.map { .init($0) }
  }

  func body(content: Content) -> some View {
    content.environment(\.swatchColors, transformedColors)
  }
}

// MARK: View Extensions

@available(macOS 10.15, *)
extension View {
  /// Adds an action to perform when a color well's color changes.
  public func onColorChange(perform action: @escaping (Color) -> Void) -> some View {
    modifier(OnColorChange(action: action))
  }
}

@available(macOS 11.0, *)
extension View {
  /// Applies the given swatch colors to the view's color wells.
  ///
  /// Swatches are user-selectable colors that are shown when
  /// a ``ColorWellView`` displays its popover.
  ///
  /// ![Default swatches](color-well-with-popover)
  ///
  /// Any color well that is part of the current view's hierarchy
  /// will update its swatches to the colors provided here.
  ///
  /// - Parameter colors: The swatch colors to use.
  public func swatchColors(_ colors: [Color]) -> some View {
    modifier(SwatchColors(colors: colors))
  }

  /// Applies the given swatch colors to the view's color wells.
  ///
  /// Swatches are user-selectable colors that are shown when
  /// a ``ColorWellView`` displays its popover.
  ///
  /// ![Default swatches](color-well-with-popover)
  ///
  /// Any color well that is part of the current view's hierarchy
  /// will update its swatches to the colors provided here.
  ///
  /// - Parameter colors: The swatch colors to use.
  public func swatchColors(_ colors: Color...) -> some View {
    swatchColors(colors)
  }
}

// MARK: - NSColorConvertible

private protocol NSColorConvertible<Converted> {
  associatedtype Converted: NSColorConvertible
  static func converted(from nsColor: NSColor) -> Converted
}

@available(macOS 10.15, *)
extension Color: NSColorConvertible {
  fileprivate static func converted(from nsColor: NSColor) -> Self {
    .init(nsColor)
  }
}

extension CGColor: NSColorConvertible {
  fileprivate static func converted(from nsColor: NSColor) -> CGColor {
    nsColor.cgColor
  }
}

@available(macOS 10.15, *)
extension StringProtocol {
  fileprivate func label() -> Text {
    .init(self)
  }
}

@available(macOS 10.15, *)
extension LocalizedStringKey {
  fileprivate func label() -> Text {
    .init(self)
  }
}

extension Never {
  fileprivate static var neverView: Self {
    fatalError("Attempted to access a view with the \(Self.self) type")
  }
}
#endif
