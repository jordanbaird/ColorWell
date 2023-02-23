//
// CustomButton.swift
// ColorWell
//

import Cocoa

/// A button that takes a closure for its action.
internal class CustomButton: NSButton {
    private let customAction: IdentifiableAction<Void>

    /// Creates a button with the given title and action.
    init(title: String, action: @escaping () -> Void) {
        self.customAction = IdentifiableAction(body: action)
        super.init(frame: .zero)
        self.title = title
        self.target = self
        self.action = #selector(performAction)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc dynamic
    private func performAction() {
        customAction()
    }
}
