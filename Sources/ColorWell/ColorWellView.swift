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

  /// A base level initializer for other initializers to
  /// delegate to.
  /// ** For internal use only **
  private init<L: View, C: CustomCocoaConvertible<NSColor, C>>(
    _color: NSColor? = nil,
    _label: () -> L,
    _action: ((C) -> Void)? = Optional<(Color) -> Void>.none
  ) {
    constructor = ViewConstructor {
      ColorWellWrapper(color: _color)
    }
    .with { view in
      if let _action {
        view.modifier(OnColorChange(action: _action))
      } else {
        view
      }
    }
    .with { view in
      view.fixedSize()
    }
    .with { view in
      if L.self is Label.Type {
        HStack {
          _label()
          view
        }
      } else {
        view
      }
    }
    .erased()
  }

  /// This initializer is the same as the one above, but
  /// its `_label` parameter is an `@autoclosure`.
  /// ** For internal use only **
  private init<L: View, C: CustomCocoaConvertible<NSColor, C>>(
    _color: NSColor? = nil,
    _label: @autoclosure () -> L,
    _action: ((C) -> Void)? = Optional<(Color) -> Void>.none
  ) {
    self.init(_color: _color, _label: _label, _action: _action)
  }
}

// MARK: ColorWellView<some View> Initializers

@available(macOS 10.15, *)
extension ColorWellView {
  /// Creates a color well that uses the provided view as its label.
  /// - Parameter label: A view that describes the purpose of the color well.
  public init(@ViewBuilder label: () -> Label) {
    self.init(_label: label)
  }

  /// Creates a color well that uses the provided view as its label,
  /// and executes the given action when its color changes.
  ///
  /// - Parameters:
  ///   - label: A view that describes the purpose of the color well.
  ///   - action: An action to perform when the color well's color changes.
  public init(@ViewBuilder label: () -> Label, action: @escaping (Color) -> Void) {
    self.init(_label: label, _action: action)
  }

  /// Creates a color well with an initial color value, with the provided
  /// view being used as the color well's label.
  ///
  /// - Parameters:
  ///   - color: The initial value of the color well's color.
  ///   - label: A view that describes the purpose of the color well.
  @available(macOS 11.0, *)
  public init(color: Color, @ViewBuilder label: () -> Label) {
    self.init(_color: .init(color), _label: label)
  }

  /// Creates a color well with an initial color value, with the provided
  /// view being used as the color well's label.
  ///
  /// - Parameters:
  ///   - cgColor: The initial value of the color well's color.
  ///   - label: A view that describes the purpose of the color well.
  public init(cgColor: CGColor, @ViewBuilder label: () -> Label) {
    self.init(_color: .init(cgColor: cgColor), _label: label)
  }

  /// Creates a color well with an initial color value, with the provided view
  /// being used as the color well's label, and the provided action being executed
  /// when the color well's color changes.
  ///
  /// - Parameters:
  ///   - color: The initial value of the color well's color.
  ///   - label: A view that describes the purpose of the color well.
  ///   - action: An action to perform when the color well's color changes.
  @available(macOS 11.0, *)
  public init(color: Color, @ViewBuilder label: () -> Label, action: @escaping (Color) -> Void) {
    self.init(_color: .init(color), _label: label, _action: action)
  }

  /// Creates a color well with an initial color value, with the provided view
  /// being used as the color well's label, and the provided action being executed
  /// when the color well's color changes.
  ///
  /// - Note: The color well's color is translated into a `CGColor` from
  ///   an underlying representation. In some cases, the translation process
  ///   may be forced to return an approximation, rather than the original
  ///   color. To receive a color that is guaranteed to be equivalent to the
  ///   color well's underlying representation, use ``init(color:label:action:)``.
  ///
  /// - Parameters:
  ///   - cgColor: The initial value of the color well's color.
  ///   - label: A view that describes the purpose of the color well.
  ///   - action: An action to perform when the color well's color changes.
  public init(cgColor: CGColor, @ViewBuilder label: () -> Label, action: @escaping (CGColor) -> Void) {
    self.init(_color: .init(cgColor: cgColor), _label: label, _action: action)
  }
}

// MARK: - ColorWellView<Never> Initializers

@available(macOS 10.15, *)
extension ColorWellView<Never> {
  /// Creates a color well initialized to its default values.
  public init() {
    self.init(_label: NoLabel())
  }

  /// Creates a color well with an initial color value.
  /// - Parameter color: The initial value of the color well's color.
  @available(macOS 11.0, *)
  public init(color: Color) {
    self.init(_color: .init(color), _label: NoLabel())
  }

  /// Creates a color well with an initial color value.
  /// - Parameter cgColor: The initial value of the color well's color.
  public init(cgColor: CGColor) {
    self.init(_color: .init(cgColor: cgColor), _label: NoLabel())
  }

  /// Creates a color well that executes the given action when its color changes.
  /// - Parameter action: An action to perform when the color well's color changes.
  public init(action: @escaping (Color) -> Void) {
    self.init(_label: NoLabel(), _action: action)
  }

  /// Creates a color well with an initial color value, that executes the
  /// given action when its color changes.
  ///
  /// - Parameters:
  ///   - color: The initial value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  @available(macOS 11.0, *)
  public init(color: Color, action: @escaping (Color) -> Void) {
    self.init(_color: .init(color), _label: NoLabel(), _action: action)
  }

  /// Creates a color well with an initial color value, that executes the
  /// given action when its color changes.
  ///
  /// - Note: The color well's color is translated into a `CGColor` from
  ///   an underlying representation. In some cases, the translation process
  ///   may be forced to return an approximation, rather than the original
  ///   color. To receive a color that is guaranteed to be equivalent to the
  ///   color well's underlying representation, use ``init(color:action:)``.
  ///
  /// - Parameters:
  ///   - cgColor: The initial value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  public init(cgColor: CGColor, action: @escaping (CGColor) -> Void) {
    self.init(_color: .init(cgColor: cgColor), _label: NoLabel(), _action: action)
  }
}

// MARK: - ColorWellView<Text> Initializers

@available(macOS 10.15, *)
extension ColorWellView<Text> {

  // MARK: From StringProtocol

  /// Creates a color well that generates its label from a string.
  /// - Parameter title: A string that describes the purpose of the color well.
  public init<S: StringProtocol>(_ title: S) {
    self.init(_label: title.label)
  }

  /// Creates a color well with an initial color value, that generates
  /// its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the color well.
  ///   - color: The initial value of the color well's color.
  @available(macOS 11.0, *)
  public init<S: StringProtocol>(_ title: S, color: Color) {
    self.init(_color: .init(color), _label: title.label)
  }

  /// Creates a color well with an initial color value, that generates
  /// its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the color well.
  ///   - cgColor: The initial value of the color well's color.
  public init<S: StringProtocol>(_ title: S, cgColor: CGColor) {
    self.init(_color: .init(cgColor: cgColor), _label: title.label)
  }

  /// Creates a color well that generates its label from a string, and
  /// performs the given action when its color changes.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the color well.
  ///   - action: An action to perform when the color well's color changes.
  public init<S: StringProtocol>(_ title: S, action: @escaping (Color) -> Void) {
    self.init(_label: title.label, _action: action)
  }

  /// Creates a color well with an initial color value that generates
  /// its label from a string, and performs the given action when its
  /// color changes.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the color well.
  ///   - color: The initial value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  @available(macOS 11.0, *)
  public init<S: StringProtocol>(_ title: S, color: Color, action: @escaping (Color) -> Void) {
    self.init(_color: .init(color), _label: title.label, _action: action)
  }

  /// Creates a color well with an initial color value that generates
  /// its label from a string, and performs the given action when its
  /// color changes.
  ///
  /// - Note: The color well's color is translated into a `CGColor` from
  ///   an underlying representation. In some cases, the translation process
  ///   may be forced to return an approximation, rather than the original
  ///   color. To receive a color that is guaranteed to be equivalent to the
  ///   color well's underlying representation, use ``init(_:color:action:)``.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the color well.
  ///   - cgColor: The initial value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  public init<S: StringProtocol>(_ title: S, cgColor: CGColor, action: @escaping (CGColor) -> Void) {
    self.init(_color: .init(cgColor: cgColor), _label: title.label, _action: action)
  }

  // MARK: From LocalizedStringKey

  /// Creates a color well that generates its label from a localized string key.
  ///
  /// - Parameter titleKey: A key for the color well's localized title, that describes
  ///   the purpose of the color well.
  public init(_ titleKey: LocalizedStringKey) {
    self.init(_label: titleKey.label)
  }

  /// Creates a color well with an initial color value, that generates its label from
  /// a localized string key.
  ///
  /// - Parameters:
  ///   - titleKey: A key for the color well's localized title, that describes the
  ///     purpose of the color well.
  ///   - color: The initial value of the color well's color.
  @available(macOS 11.0, *)
  public init(_ titleKey: LocalizedStringKey, color: Color) {
    self.init(_color: .init(color), _label: titleKey.label)
  }

  /// Creates a color well with an initial color value, that generates its label from
  /// a localized string key.
  ///
  /// - Parameters:
  ///   - titleKey: A key for the color well's localized title, that describes the
  ///     purpose of the color well.
  ///   - cgColor: The initial value of the color well's color.
  public init(_ titleKey: LocalizedStringKey, cgColor: CGColor) {
    self.init(_color: .init(cgColor: cgColor), _label: titleKey.label)
  }

  /// Creates a color well that generates its label from a localized string key,
  /// and performs the given action when its color changes.
  ///
  /// - Parameters:
  ///   - titleKey: A key for the color well's localized title, that describes the
  ///     purpose of the color well.
  ///   - action: An action to perform when the color well's color changes.
  public init(_ titleKey: LocalizedStringKey, action: @escaping (Color) -> Void) {
    self.init(_label: titleKey.label, _action: action)
  }

  /// Creates a color well with an initial color value that generates its label from
  /// a localized string key, and performs the given action when its color changes.
  ///
  /// - Parameters:
  ///   - titleKey: A key for the color well's localized title, that describes the
  ///     purpose of the color well.
  ///   - color: The initial value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  @available(macOS 11.0, *)
  public init(_ titleKey: LocalizedStringKey, color: Color, action: @escaping (Color) -> Void) {
    self.init(_color: .init(color), _label: titleKey.label, _action: action)
  }

  /// Creates a color well with an initial color value that generates its label from
  /// a localized string key, and performs the given action when its color changes.
  ///
  /// - Note: The color well's color is translated into a `CGColor` from
  ///   an underlying representation. In some cases, the translation process
  ///   may be forced to return an approximation, rather than the original
  ///   color. To receive a color that is guaranteed to be equivalent to the
  ///   color well's underlying representation, use ``init(_:color:action:)``.
  ///
  /// - Parameters:
  ///   - titleKey: A key for the color well's localized title, that describes the
  ///     purpose of the color well.
  ///   - cgColor: The initial value of the color well's color.
  ///   - action: An action to perform when the color well's color changes.
  public init(_ titleKey: LocalizedStringKey, cgColor: CGColor, action: @escaping (CGColor) -> Void) {
    self.init(_color: .init(cgColor: cgColor), _label: titleKey.label, _action: action)
  }
}

// MARK: - NoLabel

@available(macOS 10.15, *)
extension ColorWellView {
  /// A special view type whose presence indicates that a `ColorWellView`'s
  /// constructor should not modify the constructed view to include a label.
  /// ** For internal use only **
  private struct NoLabel: View {
    var body: Never { fatalError() }
  }
}

// MARK: - Environment Keys

@available(macOS 10.15, *)
private struct ChangeHandlersKey: EnvironmentKey {
  static let defaultValue = Set<ChangeHandler>()
}

@available(macOS 11.0, *)
private struct SwatchColorsKey: EnvironmentKey {
  static let defaultValue = ColorWell.defaultSwatchColors
}

// MARK: - Environment Values

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

// MARK: - View Modifiers

@available(macOS 10.15, *)
private struct OnColorChange<C: CustomCocoaConvertible<NSColor, C>>: ViewModifier {
  let id = ComparableID()
  let action: (C) -> Void

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

// MARK: - View Extensions

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
#endif
