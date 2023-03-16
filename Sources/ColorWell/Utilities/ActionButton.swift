//
// ActionButton.swift
// ColorWell
//

import Cocoa

/// A button that takes a closure for its action.
class ActionButton: NSButton {
    private let _action: () -> Void

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

    @objc private func performAction() {
        _action()
    }
}
