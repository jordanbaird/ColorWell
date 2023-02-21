//===----------------------------------------------------------------------===//
//
// CustomButton.swift
//
//===----------------------------------------------------------------------===//

import Cocoa

internal class CustomButton: NSButton {
    private let customAction: IdentifiableAction<Void>

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
    func performAction() {
        customAction()
    }
}
