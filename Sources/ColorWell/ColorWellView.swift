//===----------------------------------------------------------------------===//
//
// ColorWellView.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
private struct _ColorWellView: NSViewRepresentable {
  typealias NSViewType = ColorWell
  
  let constructor: () -> ColorWell
  
  func makeNSView(context: Context) -> ColorWell {
    constructor()
  }
  
  func updateNSView(_ nsView: ColorWell, context: Context) {
    nsView.changeHandlers.formUnion(context.environment.colorWellTransformedActions)
    nsView.isEnabled = context.environment.isEnabled
    
    if #available(macOS 11.0, *) {
      nsView.swatchColors = context.environment.colorWellSwatchColors
      nsView.color = context.environment.colorWellColor
    }
  }
}

@available(macOS 10.15, *)
public struct ColorWellView: View {
  private let frame: CGRect
  
  public init(frame: CGRect) {
    self.frame = frame
  }
  
  public init() {
    frame = ColorWell.defaultFrame
  }
  
  public var body: some View {
    _ColorWellView {
      ColorWell(frame: frame)
    }
    .frame(width: frame.width, height: frame.height)
  }
}

@available(macOS 10.15, *)
private struct ColorWellTransformedActionsKey: EnvironmentKey {
  static let defaultValue = Set<ChangeHandler>()
}

@available(macOS 11.0, *)
private struct ColorWellSwatchColorsKey: EnvironmentKey {
  static let defaultValue = [NSColor]()
}

@available(macOS 11.0, *)
private struct ColorWellColorKey: EnvironmentKey {
  static let defaultValue = ColorWell.defaultColor
}

@available(macOS 10.15, *)
private extension EnvironmentValues {
  var colorWellTransformedActions: Set<ChangeHandler> {
    get { self[ColorWellTransformedActionsKey.self] }
    set { self[ColorWellTransformedActionsKey.self] = newValue }
  }
}

@available(macOS 11.0, *)
private extension EnvironmentValues {
  var colorWellSwatchColors: [NSColor] {
    get { self[ColorWellSwatchColorsKey.self] }
    set { self[ColorWellSwatchColorsKey.self] = newValue }
  }
  
  var colorWellColor: NSColor {
    get { self[ColorWellColorKey.self] }
    set { self[ColorWellColorKey.self] = newValue }
  }
}

@available(macOS 10.15, *)
private struct ColorWellAction: ViewModifier {
  let id = ComparableID()
  let action: (Color) -> Void
  
  var transformedAction: ChangeHandler {
    ChangeHandler(id: id) {
      action(Color($0))
    }
  }
  
  func body(content: Content) -> some View {
    content.transformEnvironment(\.colorWellTransformedActions) {
      $0.insert(transformedAction)
    }
  }
}

@available(macOS 11.0, *)
private struct ColorWellSwatchColors: ViewModifier {
  let colors: [Color]
  
  var transformedColors: [NSColor] {
    colors.map { .init($0) }
  }
  
  func body(content: Content) -> some View {
    content.environment(\.colorWellSwatchColors, transformedColors)
  }
}

@available(macOS 11.0, *)
private struct ColorWellColor: ViewModifier {
  let color: Color
  
  var transformedColor: NSColor {
    .init(color)
  }
  
  func body(content: Content) -> some View {
    content.environment(\.colorWellColor, transformedColor)
  }
}

@available(macOS 10.15, *)
extension View {
  /// Adds an action to perform when a color well's color changes.
  public func onColorChange(perform action: @escaping (Color) -> Void) -> some View {
    modifier(ColorWellAction(action: action))
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
    modifier(ColorWellSwatchColors(colors: colors))
  }
  
  /// Sets the color for the color wells in this view.
  ///
  /// - Parameter color: The color to use.
  public func colorWellColor(_ color: Color) -> some View {
    modifier(ColorWellColor(color: color))
  }
}
#endif
