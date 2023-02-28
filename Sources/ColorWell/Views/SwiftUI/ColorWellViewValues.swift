//
// ColorWellViewValues.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI

/// Values used to construct a color well.
@available(macOS 10.15, *)
internal struct ColorWellViewValues {
    /// The type-erased content view of the color well.
    let erasedContent: () -> AnyView

    init<Label: View, L: View, C: CustomNSColorConvertible>(
        _: Label.Type,
        color: NSColor? = nil,
        label: () -> L,
        action: ((C) -> Void)? = Optional<(Color) -> Void>.none,
        showsAlpha: Binding<Bool>? = nil
    ) where C.ConvertedType == C {
        erasedContent = ColorWellViewLayout(Label.self, label: label) {
            ColorWellViewRepresentable(color: color, showsAlpha: showsAlpha)
                .onColorChange(maybePerform: action)
                .fixedSize()
        }.erased
    }

    init<Label: View, L: View, C: CustomNSColorConvertible>(
        _: Label.Type,
        color: NSColor? = nil,
        label: @autoclosure () -> L,
        action: ((C) -> Void)? = Optional<(Color) -> Void>.none,
        showsAlpha: Binding<Bool>? = nil
    ) where C.ConvertedType == C {
        self.init(
            Label.self,
            color: color,
            label: label,
            action: action,
            showsAlpha: showsAlpha
        )
    }
}
#endif
