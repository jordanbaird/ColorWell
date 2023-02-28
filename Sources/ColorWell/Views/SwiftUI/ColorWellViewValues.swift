//
// ColorWellViewValues.swift
// ColorWell
//

import Cocoa
#if canImport(SwiftUI)
import SwiftUI

/// Values used to construct a color well.
@available(macOS 10.15, *)
internal struct ColorWellViewValues<Label: View, LabelCandidate: View> {
    let color: NSColor?

    let label: () -> LabelCandidate

    let action: ((NSColor) -> Void)?

    let showsAlpha: Binding<Bool>?

    @ViewBuilder var content: some View {
        ColorWellViewLayout(values: self)
    }

    init(
        _: Label.Type,
        color: NSColor? = nil,
        label: () -> LabelCandidate,
        action: ((NSColor) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
        self.color = color
        self.label = makeIndirect(label)
        self.action = action
        self.showsAlpha = showsAlpha
    }

    @available(macOS 11.0, *)
    init(
        _: Label.Type,
        color: Color?,
        label: () -> LabelCandidate,
        action: ((Color) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
        self.init(
            Label.self,
            color: color.map(NSColor.init),
            label: label,
            action: action.map { action in
                let converted: (NSColor) -> Void = { color in
                    action(Color(color))
                }
                return converted
            },
            showsAlpha: showsAlpha
        )
    }

    init(
        _: Label.Type,
        label: () -> LabelCandidate,
        action: ((Color) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
        self.init(
            Label.self,
            color: nil,
            label: label,
            action: action.map { action in
                let converted: (NSColor) -> Void = { color in
                    action(Color(color))
                }
                return converted
            },
            showsAlpha: showsAlpha
        )
    }

    @available(macOS 11.0, *)
    init(
        _: Label.Type,
        color: Color? = nil,
        label: @autoclosure () -> LabelCandidate,
        action: ((Color) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
        self.init(
            Label.self,
            color: color,
            label: label,
            action: action,
            showsAlpha: showsAlpha
        )
    }

    init(
        _: Label.Type,
        label: @autoclosure () -> LabelCandidate,
        action: ((Color) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
        self.init(
            Label.self,
            label: label,
            action: action,
            showsAlpha: showsAlpha
        )
    }

    init(
        _: Label.Type,
        color: CGColor? = nil,
        label: () -> LabelCandidate,
        action: ((CGColor) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
        self.init(
            Label.self,
            color: color.flatMap(NSColor.init),
            label: label,
            action: action.map { action in
                let converted: (NSColor) -> Void = { color in
                    action(color.cgColor)
                }
                return converted
            },
            showsAlpha: showsAlpha
        )
    }

    init(
        _: Label.Type,
        color: CGColor? = nil,
        label: @autoclosure () -> LabelCandidate,
        action: ((CGColor) -> Void)? = nil,
        showsAlpha: Binding<Bool>? = nil
    ) {
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
