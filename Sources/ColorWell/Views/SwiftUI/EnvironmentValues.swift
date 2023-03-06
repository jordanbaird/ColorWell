//
// EnvironmentValues.swift
// ColorWell
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ChangeHandlersKey

/// A key used to store a color well's change handlers in an environment.
@available(macOS 10.15, *)
private struct ChangeHandlersKey: EnvironmentKey {
    static let defaultValue = [(NSColor) -> Void]()
}

// MARK: - ColorWellStyleConfigurationKey

/// A key used to store a color well's style configuration in an environment.
@available(macOS 10.15, *)
private struct ColorWellStyleConfigurationKey: EnvironmentKey {
    static let defaultValue = _ColorWellStyleConfiguration()
}

// MARK: - SwatchColorsKey

/// A key used to store a color well's swatch colors in an environment.
@available(macOS 10.15, *)
private struct SwatchColorsKey: EnvironmentKey {
    static let defaultValue: [NSColor]? = nil
}

// MARK: - EnvironmentValues

@available(macOS 10.15, *)
extension EnvironmentValues {
    /// The change handlers to add to the color wells in this environment.
    var changeHandlers: [(NSColor) -> Void] {
        get { self[ChangeHandlersKey.self] }
        set { self[ChangeHandlersKey.self] = newValue }
    }

    /// The style configuration to apply to the color wells in this environment.
    var colorWellStyleConfiguration: _ColorWellStyleConfiguration {
        get { self[ColorWellStyleConfigurationKey.self] }
        set { self[ColorWellStyleConfigurationKey.self] = newValue }
    }

    /// The swatch colors to apply to the color wells in this environment.
    var swatchColors: [NSColor]? {
        get { self[SwatchColorsKey.self] }
        set { self[SwatchColorsKey.self] = newValue }
    }
}
#endif
