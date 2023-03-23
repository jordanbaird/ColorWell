//
// ColorWellPopoverLayoutView.swift
// ColorWell
//

import Cocoa

/// A view that provides the layout for a color well's popover.
class ColorWellPopoverLayoutView: NSGridView {
    /// A context that manages the elements of the layout view's popover.
    private weak var context: ColorWellPopoverContext?

    /// A button that, when pressed, activates the color well
    /// and closes the popover.
    var activationButton: ActionButton? {
        didSet {
            if let oldValue {
                oldValue.removeFromSuperview()
                oldValue.setAccessibilityParent(nil)
                if
                    let cell = cell(for: oldValue),
                    let row = cell.row
                {
                    let rowIndex = index(of: row)
                    removeRow(at: rowIndex)
                }
            }
            if let activationButton {
                addRow(with: [activationButton])
                cell(for: activationButton)?.xPlacement = .fill
                activationButton.setAccessibilityParent(self)
            }
        }
    }

    /// Creates a layout view with the specified context.
    init(context: ColorWellPopoverContext) {
        self.context = context
        super.init(frame: .zero)
        addRow(with: [context.swatchView])
        setActivationButtonIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActivationButtonIfNeeded() {
        guard context?.colorWell?.style == .swatches else {
            return
        }
        activationButton = ActionButton(title: "Show More Colors…") { [weak context] in
            context?.colorWell?.activateAutoVerifyingExclusive()
            context?.popover.close()
        }
        activationButton?.bezelStyle = .recessed
        activationButton?.controlSize = .small
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
