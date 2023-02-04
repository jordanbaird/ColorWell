//===----------------------------------------------------------------------===//
//
// ColorWellView.swift
//
//===----------------------------------------------------------------------===//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - RootView

@available(macOS 10.15, *)
private struct RootView: NSViewRepresentable {
    let color: NSColor?

    @Binding var showsAlpha: Bool

    func makeNSView(context: Context) -> ColorWell {
        if let color {
            return ColorWell(color: color)
        } else {
            return ColorWell()
        }
    }

    func updateNSView(_ nsView: ColorWell, context: Context) {
        nsView.showsAlpha = showsAlpha
        nsView.insertChangeHandlers(context.environment.changeHandlers)
        nsView.isEnabled = context.environment.isEnabled

        if #available(macOS 11.0, *) {
            nsView.swatchColors = context.environment.swatchColors
        }
    }
}

// MARK: - ColorWellView

/// A SwiftUI view that displays a user-settable color value.
///
/// Color wells enable the user to select custom colors from within an app's
/// interface. A graphics app might, for example, include a color well to let
/// someone choose the fill color for a shape. Color wells display the currently
/// selected color, and interactions with the color well display interfaces
/// for selecting new colors.
@available(macOS 10.15, *)
public struct ColorWellView<Label: View>: View {
    private let constructor: AnyViewConstructor

    /// The content of the color well.
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
        // TODO: _showsAlpha: Binding<Bool>
    ) {
        constructor = ViewConstructor {
            // TODO: Need an API that accepts a Binding<Bool> for showsAlpha.
            // For now, we'll just pass a constant.
            RootView(color: _color, showsAlpha: .constant(true))
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
            LayoutView(Label.self, label: _label(), content: view)
        }
        .erased()
    }

    /// A base level initializer for other initializers to
    /// delegate to, whose `_label` parameter is an `@autoclosure`.
    /// ** For internal use only **
    private init<L: View, C: CustomCocoaConvertible<NSColor, C>>(
        _color: NSColor? = nil,
        _label: @autoclosure () -> L,
        _action: ((C) -> Void)? = Optional<(Color) -> Void>.none
        // TODO: _showsAlpha: Binding<Bool>
    ) {
        self.init(_color: _color, _label: _label, _action: _action/*, _showsAlpha: _showsAlpha*/)
    }
}

// MARK: ColorWellView Initializers (Label: View)
@available(macOS 10.15, *)
extension ColorWellView {
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

// MARK: ColorWellView Initializers (Label == Never)
@available(macOS 10.15, *)
extension ColorWellView<Never> {
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

// MARK: ColorWellView Initializers (Label == Text)
@available(macOS 10.15, *)
extension ColorWellView<Text> {
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
}

// MARK: - NoLabel

/// A special view type whose presence indicates that a `ColorWellView`'s
/// constructor should not modify the constructed view to include a label.
/// ** For internal use only **
@available(macOS 10.15, *)
private struct NoLabel: View {
    var body: Never { fatalError() }
}

// MARK: - LayoutView

/// A view that manages the layout of a `ColorWellView` and its label.
///
/// Its initializer takes a label candidate and content view. It validates
/// the label candidate's type to ensure that it meets the criteria to be
/// included as part of the constructed view. If the candidate fails
/// validation, only the content view will be included.
/// ** For internal use only **
@available(macOS 10.15, *)
private struct LayoutView<Label: View, LabelCandidate: View, Content: View>: View {
    private let constructor: AnyViewConstructor

    var body: some View {
        constructor
    }

    init(
        _ labelType: Label.Type,
        label: @autoclosure () -> LabelCandidate,
        content: @autoclosure () -> Content
    ) {
        guard
            LabelCandidate.self == Label.self,
            Label.self != NoLabel.self
        else {
            constructor = AnyViewConstructor(content: content)
            return
        }
        let content = HStack(alignment: .center) {
            label()
            content()
        }
        constructor = AnyViewConstructor(content: content)
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
extension EnvironmentValues {
    internal var changeHandlers: Set<ChangeHandler> {
        get { self[ChangeHandlersKey.self] }
        set { self[ChangeHandlersKey.self] = newValue }
    }
}

@available(macOS 11.0, *)
extension EnvironmentValues {
    internal var swatchColors: [NSColor] {
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
    /// ![Default swatches](grid-view)
    ///
    /// Any color well that is part of the current view's hierarchy
    /// will update its swatches to the colors provided here.
    ///
    /// - Parameter colors: The swatch colors to use.
    public func swatchColors(_ colors: [Color]) -> some View {
        modifier(SwatchColors(colors: colors))
    }
}
#endif
