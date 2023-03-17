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
    var activationButton: ActionButton? {
        didSet {
            oldValue?.setAccessibilityParent(nil)
            activationButton?.setAccessibilityParent(self)
        }
    }

    init(context: ColorWellPopoverContext) {
        self.context = context

        super.init(frame: .zero)

        addRow(with: [context.swatchView])

        switch context.colorWell?.style {
        case .swatches:
            let activationButton = ActionButton(title: "Show More Colors…") { [weak context] in
                context?.colorWell?.activateAutoVerifyingExclusive()
                context?.popover.close()
            }
            self.activationButton = activationButton

            activationButton.bezelStyle = .recessed
            activationButton.controlSize = .small
            
            addRow(with: [activationButton])
            cell(for: activationButton)?.xPlacement = .fill
        default:
            break
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Accessibility
extension ColorWellPopoverLayoutView {
    override func accessibilityParent() -> Any? {
        context?.containerView
    }

    override func accessibilityChildren() -> [Any]? {
        var result = [Any]()
        if let swatchView = context?.swatchView {
            result.append(swatchView)
        }
        if let activationButton {
            result.append(activationButton)
        }
        return result.isEmpty ? nil : result
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .layoutArea
    }
}
