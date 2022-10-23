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
    if let transformedAction = context.environment.colorWellTransformedAction {
      nsView.changeHandlers.insert(transformedAction)
    }
    if #available(macOS 11.0, *) {
      nsView.swatchColors = context.environment.swatchColors.map {
        .init($0)
      }
      
      let color = NSColor(context.environment.colorWellColor)
      if nsView.color != color {
        nsView.color = color
      }
    }
  }
}

@available(macOS 10.15, *)
public struct ColorWellView: View {
  private let frame: CGRect?
  
  public init(frame: CGRect) {
    self.frame = frame
  }
  
  public init() {
    frame = nil
  }
  
  public var body: some View {
    if let frame {
      return _ColorWellView {
        ColorWell(frame: frame)
      }
    } else {
      return _ColorWellView {
        ColorWell()
      }
    }
  }
}

@available(macOS 10.15, *)
private struct ColorWellTransformedActionKey: EnvironmentKey {
  static let defaultValue: ChangeHandler? = nil
}

@available(macOS 11.0, *)
private struct SwatchColorsKey: EnvironmentKey {
  static let defaultValue = [Color]()
}

@available(macOS 11.0, *)
private struct ColorWellColorKey: EnvironmentKey {
  static let defaultValue = Color(ColorWell.defaultColor)
}

@available(macOS 10.15, *)
private extension EnvironmentValues {
  var colorWellTransformedAction: ChangeHandler? {
    get { self[ColorWellTransformedActionKey.self] }
    set { self[ColorWellTransformedActionKey.self] = newValue }
  }
}

@available(macOS 11.0, *)
private extension EnvironmentValues {
  var swatchColors: [Color] {
    get { self[SwatchColorsKey.self] }
    set { self[SwatchColorsKey.self] = newValue }
  }
  
  var colorWellColor: Color {
    get { self[ColorWellColorKey.self] }
    set { self[ColorWellColorKey.self] = newValue }
  }
}

@available(macOS 10.15, *)
private struct ColorWellAction: ViewModifier {
  let action: (Color) -> Void
  
  var transformedAction: ChangeHandler {
    ChangeHandler { action(Color($0)) }
  }
  
  func body(content: Content) -> some View {
    content.environment(\.colorWellTransformedAction, transformedAction)
  }
}

@available(macOS 11.0, *)
private struct SwatchColors: ViewModifier {
  let colors: [Color]
  
  func body(content: Content) -> some View {
    content.environment(\.swatchColors, colors)
  }
}

@available(macOS 11.0, *)
private struct ColorWellColor: ViewModifier {
  let color: Color
  
  func body(content: Content) -> some View {
    content.environment(\.colorWellColor, color)
  }
}

@available(macOS 10.15, *)
extension View {
  /// Sets an action that will be run when the color well's
  /// color changes.
  public func colorWellAction(_ action: @escaping (Color) -> Void) -> some View {
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
    modifier(SwatchColors(colors: colors))
  }
  
  /// Sets the color for the color wells in this view.
  ///
  /// - Parameter color: The color to use.
  public func colorWellColor(_ color: Color) -> some View {
    modifier(ColorWellColor(color: color))
  }
}
#endif
