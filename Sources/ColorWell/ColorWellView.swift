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
        nsView.appendUniqueChangeHandlers(context.environment.changeHandlers.reversed())
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
    private let content: AnyView

    /// The content view of the color well.
    public var body: some View {
        content
    }

    /// A base level initializer for other initializers to
    /// delegate to.
    /// ** For internal use only **
    private init<L: View, C: CustomCocoaConvertible>(
        _color: NSColor? = nil,
        _label: () -> L,
        _action: ((C) -> Void)? = Optional<(Color) -> Void>.none
        // TODO: _showsAlpha: Binding<Bool>
    ) where C.CocoaType == NSColor,
            C.Converted == C
    {
        content = LayoutView(
            Label.self,
            label: {
                _label()
            },
            content: {
                // TODO: Need an API that accepts a Binding<Bool> for showsAlpha.
                // For now, we'll just pass a constant.
                RootView(color: _color, showsAlpha: .constant(true))
                    .onColorChange(maybePerform: _action)
                    .fixedSize()
            }
        )
        .erased()
    }

    /// A base level initializer for other initializers to
    /// delegate to, whose `_label` parameter is an `@autoclosure`.
    /// ** For internal use only **
    private init<L: View, C: CustomCocoaConvertible>(
        _color: NSColor? = nil,
        _label: @autoclosure () -> L,
        _action: ((C) -> Void)? = Optional<(Color) -> Void>.none
        // TODO: _showsAlpha: Binding<Bool>
    ) where C.CocoaType == NSColor,
            C.Converted == C
    {
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
        self.init(_color: NSColor(color), _label: label)
    }

    /// Creates a color well with an initial color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - cgColor: The initial value of the color well's color.
    ///   - label: A view that describes the purpose of the color well.
    public init(cgColor: CGColor, @ViewBuilder label: () -> Label) {
        self.init(_color: NSColor(cgColor: cgColor), _label: label)
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
        self.init(_color: NSColor(color), _label: label, _action: action)
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
        self.init(_color: NSColor(cgColor: cgColor), _label: label, _action: action)
    }
}

// MARK: ColorWellView Initializers (Label == Never)
@available(macOS 10.15, *)
extension ColorWellView<Never> {
    /// Creates a color well with an initial color value.
    ///
    /// - Parameter color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init(color: Color) {
        self.init(_color: NSColor(color), _label: NoLabel())
    }

    /// Creates a color well with an initial color value.
    ///
    /// - Parameter cgColor: The initial value of the color well's color.
    public init(cgColor: CGColor) {
        self.init(_color: NSColor(cgColor: cgColor), _label: NoLabel())
    }

    /// Creates a color well with an initial color value, that executes the
    /// given action when its color changes.
    ///
    /// - Parameters:
    ///   - color: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(color: Color, action: @escaping (Color) -> Void) {
        self.init(_color: NSColor(color), _label: NoLabel(), _action: action)
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
        self.init(_color: NSColor(cgColor: cgColor), _label: NoLabel(), _action: action)
    }
}

// MARK: ColorWellView Initializers (Label == Text)
@available(macOS 10.15, *)
extension ColorWellView<Text> {

    // MARK: Generate Label From StringProtocol

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(_ title: S, color: Color) {
        self.init(_color: NSColor(color), _label: Text(title))
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    public init<S: StringProtocol>(_ title: S, cgColor: CGColor) {
        self.init(_color: NSColor(cgColor: cgColor), _label: Text(title))
    }

    /// Creates a color well that generates its label from a string, and
    /// performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(_ title: S, action: @escaping (Color) -> Void) {
        self.init(_label: Text(title), _action: action)
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
        self.init(_color: NSColor(color), _label: Text(title), _action: action)
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a string, and performs the given action when its
    /// color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:action:)-8ghst``.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    public init<S: StringProtocol>(_ title: S, cgColor: CGColor, action: @escaping (CGColor) -> Void) {
        self.init(_color: NSColor(cgColor: cgColor), _label: Text(title), _action: action)
    }

    // MARK: Generate Label From LocalizedStringKey

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    @available(macOS 11.0, *)
    public init(_ titleKey: LocalizedStringKey, color: Color) {
        self.init(_color: NSColor(color), _label: Text(titleKey))
    }

    /// Creates a color well with an initial color value, that generates
    /// its label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    public init(_ titleKey: LocalizedStringKey, cgColor: CGColor) {
        self.init(_color: NSColor(cgColor: cgColor), _label: Text(titleKey))
    }

    /// Creates a color well that generates its label from a localized
    /// string key, and performs the given action when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - action: An action to perform when the color well's color changes.
    public init(_ titleKey: LocalizedStringKey, action: @escaping (Color) -> Void) {
        self.init(_label: Text(titleKey), _action: action)
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - color: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    @available(macOS 11.0, *)
    public init(_ titleKey: LocalizedStringKey, color: Color, action: @escaping (Color) -> Void) {
        self.init(_color: NSColor(color), _label: Text(titleKey), _action: action)
    }

    /// Creates a color well with an initial color value that generates
    /// its label from a localized string key, and performs the given action
    /// when its color changes.
    ///
    /// - Note: The color well's color is translated into a `CGColor` from
    ///   an underlying representation. In some cases, the translation process
    ///   may be forced to return an approximation, rather than the original
    ///   color. To receive a color that is guaranteed to be equivalent to the
    ///   color well's underlying representation, use ``init(_:color:action:)-3s0o1``.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - cgColor: The initial value of the color well's color.
    ///   - action: An action to perform when the color well's color changes.
    public init(_ titleKey: LocalizedStringKey, cgColor: CGColor, action: @escaping (CGColor) -> Void) {
        self.init(_color: NSColor(cgColor: cgColor), _label: Text(titleKey), _action: action)
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
    private let erasedContent: AnyView

    var body: some View {
        erasedContent
    }

    init(
        _ labelType: Label.Type,
        @ViewBuilder label: () -> LabelCandidate,
        @ViewBuilder content: () -> Content
    ) {
        guard
            LabelCandidate.self == Label.self,
            Label.self != NoLabel.self
        else {
            erasedContent = content().erased()
            return
        }
        erasedContent = HStack(alignment: .center) {
            label()
            content()
        }
        .erased()
    }
}

// MARK: - ChangeHandlersKey

@available(macOS 10.15, *)
internal struct ChangeHandlersKey: EnvironmentKey {
    static let defaultValue = [ChangeHandler]()
}

// MARK: - SwatchColorsKey

@available(macOS 11.0, *)
internal struct SwatchColorsKey: EnvironmentKey {
    static let defaultValue = ColorWell.defaultSwatchColors
}

// MARK: - EnvironmentValues Change Handlers

@available(macOS 10.15, *)
extension EnvironmentValues {
    internal var changeHandlers: [ChangeHandler] {
        get { self[ChangeHandlersKey.self] }
        set { self[ChangeHandlersKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues Swatch Colors

@available(macOS 11.0, *)
extension EnvironmentValues {
    internal var swatchColors: [NSColor] {
        get { self[SwatchColorsKey.self] }
        set { self[SwatchColorsKey.self] = newValue }
    }
}

// MARK: - OnColorChange

@available(macOS 10.15, *)
internal struct OnColorChange<C: CustomCocoaConvertible>: ViewModifier
    where C.CocoaType == NSColor,
          C.Converted == C
{
    let id = UUID()
    let action: ((C) -> Void)?

    var transformedAction: ChangeHandler? {
        action.map { action in
            ChangeHandler(id: id) {
                action(C.converted(from: $0))
            }
        }
    }

    func body(content: Content) -> some View {
        content.transformEnvironment(\.changeHandlers) { changeHandlers in
            if let transformedAction {
                changeHandlers.appendUnique(transformedAction)
            }
        }
    }
}

// MARK: - SwatchColors

@available(macOS 11.0, *)
internal struct SwatchColors: ViewModifier {
    let colors: [Color]

    var transformedColors: [NSColor] {
        colors.map {
            NSColor($0)
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.swatchColors, transformedColors)
    }
}

// MARK: - View On Color Change

@available(macOS 10.15, *)
extension View {
    fileprivate func onColorChange<C: CustomCocoaConvertible>(maybePerform action: ((C) -> Void)?) -> some View
        where C.CocoaType == NSColor,
              C.Converted == C
    {
        modifier(OnColorChange(action: action))
    }

    /// Adds an action to perform when a color well's color changes.
    public func onColorChange(perform action: @escaping (Color) -> Void) -> some View {
        onColorChange(maybePerform: action)
    }
}

// MARK: - View Swatch Colors

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
