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
    }
  }
}

@available(macOS 10.15, *)
public struct ColorWellView: View {
  let color: NSColor?

  /// Creates a color well with the default color.
  public init() {
    color = nil
  }

  /// Creates a color well view with the given color.
  @available(macOS 11.0, *)
  public init(color: Color) {
    self.color = .init(color)
  }

  /// Creates a color well view with the given CoreGraphics color.
  public init(cgColor: CGColor) {
    color = .init(cgColor: cgColor)
  }

  public var body: some View {
    _ColorWellView {
      if let color {
        return ColorWell(color: color)
      } else {
        return ColorWell()
      }
    }
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
}
#endif
