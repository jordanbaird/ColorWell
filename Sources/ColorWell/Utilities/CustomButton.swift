//
// CustomButton.swift
// ColorWell
//

import Cocoa

/// A button that takes a closure for its action.
internal class CustomButton: NSButton {
    /// The button's stored action.
    private let _action: () -> Void

    /// Creates a button with the given title and action.
    init(title: String, action: @escaping () -> Void) {
        self._action = action
        super.init(frame: .zero)
        self.title = title
        self.target = self
        self.action = #selector(performAction)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Executes the button's stored action.
    @objc private func performAction() {
        _action()
    }
}
