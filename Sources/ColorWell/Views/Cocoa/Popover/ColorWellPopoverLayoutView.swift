//
// ColorWellPopoverLayoutView.swift
// ColorWell
//

import Cocoa

/// A view that provides the layout for a color well's popover.
class ColorWellPopoverLayoutView: NSGridView {
    private weak var context: ColorWellPopoverContext?

    /// A button that, when pressed, activates the color well
    /// and closes the popover.
    var activateButton: ActionButton? {
        didSet {
            oldValue?.setAccessibilityParent(nil)
            activateButton?.setAccessibilityParent(self)
        }
    }

    init(context: ColorWellPopoverContext) {
        self.context = context

        super.init(frame: .zero)

        addRow(with: [context.swatchView])

        switch context.colorWell?.style {
        case .swatches:
            let activateButton = ActionButton(title: "Show More Colors…") { [weak context] in
                context?.colorWell?.activateAutoVerifyingExclusive()
                context?.popover.close()
            }
            self.activateButton = activateButton

            activateButton.bezelStyle = .recessed
            activateButton.controlSize = .small
            
            addRow(with: [activateButton])
            cell(for: activateButton)?.xPlacement = .fill
        default:
            break
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Accessibility

    override func accessibilityParent() -> Any? {
        context?.containerView
    }

    override func accessibilityChildren() -> [Any]? {
        var result = [Any]()
        if let swatchView = context?.swatchView {
            result.append(swatchView)
        }
        if let activateButton {
            result.append(activateButton)
        }
        return result.isEmpty ? nil : result
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .layoutArea
    }
}
